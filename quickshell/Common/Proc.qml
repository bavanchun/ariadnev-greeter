pragma Singleton

import Quickshell
import qs.AdvCommon.Common as AdvCommon

Singleton {
    readonly property string advsBin: AdvCommon.Proc.advsBin

    function runCommand(id, command, callback, debounceMs, timeoutMs) {
        AdvCommon.Proc.runCommand(id, command, callback, debounceMs, timeoutMs);
    }
}
