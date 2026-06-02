import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pam

Scope {
    id: root
    signal unlocked
    signal failed
    signal actionConfirmed

    property string currentText: ""
    property string targetAction: "unlock"
    property bool unlockInProgress: false
    property bool showFailure: false
    property bool showSuccess: false

    onCurrentTextChanged: showFailure = false

    // TODO: maybe remove this now that i alr filmed? welp
    function stopRecording(): void {
        stopRecordings.command = ["sh", "-c", "if [ -f /tmp/lock_recorder.pid ]; then kill $(cat /tmp/lock_recorder.pid) 2>/dev/null; rm -f /tmp/lock_recorder.pid; fi"];
        stopRecordings.running = true;
    }

    Process {
        id: stopRecordings
        running: false
        onExited: running = false
    }

    function tryUnlock() {
        if (currentText === "" || root.unlockInProgress)
            return;
        root.unlockInProgress = true;
        pam.start();
    }

    function confirmAction() {
        root.showSuccess = true;
        root.actionConfirmed();
    }

    PamContext {
        id: pam
        configDirectory: "pam"
        // TODO: maybe dont rely on the nodelay?
        config: "password.conf"

        onPamMessage: {
            if (this.responseRequired) {
                root.currentText = root.currentText.trim(); // Just in case
                this.respond(root.currentText);
            }
        }

        onCompleted: result => {
            if (result == PamResult.Success) {
                if (root.targetAction === "poweroff") {
                    Quickshell.execDetached(["poweroff"]);
                    return;
                } else if (root.targetAction === "reboot") {
                    Quickshell.execDetached(["reboot"]);
                    return;
                }

                if (Quickshell.env("QS_UNLOCK_KEYRING") === "true") {
                    Quickshell.execDetached({
                        environment: ({ "UNLOCK_PASSWORD": root.currentText }),
                        command: ["bash", "-c", Quickshell.env("HOME") + "/.config/qylock/themes/nierlock/pam/unlock.sh"]
                    });
                }

                root.showSuccess = true;
                successDelayTimer.start();
                console.log("yes");
            } else {
                root.currentText = "";
                root.showFailure = true;
                console.log("no");
                root.failed();
            }
            root.unlockInProgress = false;
        }
    }

    Timer {
        id: successDelayTimer
        interval: Config.shaderDelay + 1000
        onTriggered: {
            stopRecording();
            root.unlocked();
        }
    }
}
