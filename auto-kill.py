import subprocess
import threading
import sys

MAX_SECONDS = int(sys.argv[1])

def get_pid():
    output = str(subprocess.check_output(["bash", "-c", "ps -e | grep KeyboardCleaner"]), "utf-8")
    return int(output.split("\n")[0].strip().split(" ")[0])
def get_uptime(pid):
    output = str(subprocess.check_output(["bash", "-c", "ps -p " + str(pid) + " -o etime"]), "utf-8")
    m, s = output.split("\n")[1].strip().split(":")
    return int(m), int(s)

def check():
    try:
        pid = get_pid()
        m, s = get_uptime(pid)
        if m * 60 + s >= MAX_SECONDS:
            subprocess.Popen(["bash", "-c", "kill -9 " + str(pid)])
        print("Killed KeyboardCleaner for exceeding the time limit!")
    except Exception:
        print("KeyboardCleaner is not open!")
    else:
        print("KeyboardCleaner is open but has not reached the time limit...")
    finally:
        threading.Timer(2.0, check).start()

check()
