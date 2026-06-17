pragma Singleton
pragma ComponentBehavior: Bound

import qs.modules.common
import Quickshell;
import qs.services
import Quickshell.Io;
import QtQuick;
import qs.modules.common.functions
import qs

Singleton {
    id: root
    property var filePath: Directories.todoPath
    property var list: []
    property bool _isFetching: false
    property string apiKey: ""

    Process {
        id: envProcess
        command: ["bash", "-c", "source ~/.config/quickshell/ii/.env 2>/dev/null && echo $TODOIST_API_KEY"]
        stdout: StdioCollector {
            id: envCollector
            onStreamFinished: {
                root.apiKey = envCollector.text.trim()
                if (root.apiKey !== "") {
                    console.log("[To Do] Todoist API Key loaded from ~/.config/quickshell/ii/.env")
                    refresh()
                } else {
                    console.log("[To Do] TODOIST_API_KEY not found. Please add it!")
                }
            }
        }
    }

    Component.onCompleted: {
        envProcess.running = true
    }

    Timer {
        interval: 30000 // 30 seconds
        running: root.apiKey !== ""
        repeat: true
        onTriggered: {
            root.refresh()
        }
    }

    Connections {
        target: GlobalStates
        function onDashboardPanelOpenChanged() {
            if (GlobalStates.dashboardPanelOpen) {
                root.refresh()
            }
        }
        function onPoliciesPanelOpenChanged() {
            if (GlobalStates.policiesPanelOpen) {
                root.refresh()
            }
        }
    }

    Process {
        id: fetchProc
        command: ["bash", "-c", Directories.scriptPath + "/todoist/todoist.sh fetch"]
        stdout: StdioCollector {
            id: fetchCollector
            onStreamFinished: {
                _isFetching = false;
                try {
                    const response = fetchCollector.text.trim()
                    if (response === "") return;
                    const parsed = JSON.parse(response);
                    
                    if (parsed.active && parsed.active.error) {
                        console.log("[To Do] Todoist Active Tasks Error:", parsed.active.error)
                        return;
                    }

                    const activeData = parsed.active || [];
                    const activeTasks = Array.isArray(activeData) ? activeData : (activeData.results || []);
                    
                    let completedTasks = [];
                    
                    if (parsed.completed && parsed.completed.items) {
                        completedTasks = parsed.completed.items;
                    }

                    const mappedActive = activeTasks.map(t => ({
                        id: String(t.id),
                        content: t.content,
                        done: false,
                        date: t.due ? new Date(t.due.date) : new Date()
                    }));

                    const mappedCompleted = completedTasks.map(t => ({
                        id: String(t.task_id || t.id),
                        content: t.content,
                        done: true,
                        date: t.completed_date ? new Date(t.completed_date) : new Date()
                    }));

                    root.list = mappedActive.concat(mappedCompleted);
                    saveCompletedTasks();
                } catch(e) {
                    console.log("[To Do] Error parsing Todoist tasks:", e)
                }
            }
        }
    }

    Process {
        id: cmdProc
        property var queue: []
        property bool isBusy: false

        onExited: {
            if (queue.length > 0) {
                const nextCmd = queue.shift()
                command = ["bash", "-c", nextCmd]
                running = true
            } else {
                isBusy = false
                root.refresh()
            }
        }

        function pushCmd(cmd) {
            queue.push(cmd)
            if (!isBusy) {
                isBusy = true
                command = ["bash", "-c", queue.shift()]
                running = true
            }
        }
    }

    property string completedTasksFile: FileUtils.trimFileProtocol(Directories.state + "/user/todoist_completed.json")

    FileView {
        id: completedFileView
        path: "file://" + root.completedTasksFile
        onLoaded: {
            try {
                const text = completedFileView.text().trim()
                if (text === "") return;
                const savedTasks = JSON.parse(text)
                
                const existingIds = root.list.map(t => t.id)
                const toAdd = savedTasks.filter(t => !existingIds.includes(t.id))
                if (toAdd.length > 0) {
                    root.list = root.list.concat(toAdd)
                }
            } catch(e) {
                console.log("[To Do] Error parsing saved completed tasks:", e)
            }
        }
        onLoadFailed: (error) => {
            if(error == FileViewError.FileNotFound) {
                completedFileView.setText("[]")
            }
        }
    }

    function saveCompletedTasks() {
        const completed = root.list.filter(t => t.done)
        completedFileView.setText(JSON.stringify(completed))
    }

    function refresh() {
        if (_isFetching || root.apiKey === "") return;
        _isFetching = true;
        fetchProc.running = false;
        fetchProc.running = true;
    }

    function addItem(item) {
        let arr = root.list.slice(0)
        arr.push(item)
        root.list = arr
        saveCompletedTasks()
    }

    function addTask(desc) {
        const tempItem = {
            id: "temp_" + Date.now(),
            content: desc,
            done: false,
            date: new Date()
        }
        addItem(tempItem)
        
        let safeDesc = desc.replace(/'/g, "'\\''")
        cmdProc.pushCmd(Directories.scriptPath + "/todoist/todoist.sh add '" + safeDesc + "'")
    }

    function getTasksByDate(currentDate) {
        const res = [];
        const currentDay = currentDate.getDate();
        const currentMonth = currentDate.getMonth();
        const currentYear = currentDate.getFullYear();

        for (let i = 0; i < root.list.length; i++) {
            if (!root.list[i].date) continue;
            const taskDate = new Date(root.list[i].date);
            if (
                taskDate.getDate() === currentDay &&
                taskDate.getMonth() === currentMonth &&
                taskDate.getFullYear() === currentYear
              ) {
                res.push(root.list[i]);
              }
        }
        return res;
    }

    function markDone(index) {
        if (index >= 0 && index < root.list.length) {
            let arr = root.list.slice(0)
            let task = arr[index]
            task.done = true
            root.list = arr

            if (task.id && !task.id.startsWith("temp_")) {
                cmdProc.pushCmd(`"${Directories.scriptPath}/todoist/todoist.sh" close "${task.id}"`)
            }
        }
    }

    function markUnfinished(index) {
        if (index >= 0 && index < root.list.length) {
            let arr = root.list.slice(0)
            let task = arr[index]
            task.done = false
            root.list = arr

            if(CalendarService.khalAvailable){ 
              return
            }
            if (task.id && !task.id.startsWith("temp_")) {
                cmdProc.pushCmd(`"${Directories.scriptPath}/todoist/todoist.sh" unclose "${task.id}"`)
            }
        }
    }

    function deleteItem(index) {
        if (index >= 0 && index < root.list.length) {
            let arr = root.list.slice(0)
            let task = arr[index]
            arr.splice(index, 1)
            root.list = arr

            if (task.id && !task.id.startsWith("temp_")) {
                cmdProc.pushCmd(`"${Directories.scriptPath}/todoist/todoist.sh" delete "${task.id}"`)
            }
        }
    }
}

