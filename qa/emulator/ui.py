#!/usr/bin/env python3
"""Minimal adb driver for Flutter apps on the Android emulator.

Flutter exposes its semantics tree to `uiautomator dump`, so labels and bounds are readable.

Usage:
  qa/emulator/ui.py dump                 # list labelled / clickable nodes with centers
  qa/emulator/ui.py tap "<text>" [n]     # tap the n-th node whose label contains text
  qa/emulator/ui.py xy X Y               # tap raw coordinates (device pixels)
  qa/emulator/ui.py type "<text>"        # type into the focused field
  qa/emulator/ui.py clear [n]            # move caret to end and delete n chars (default 40)
  qa/emulator/ui.py hidekb               # hide the keyboard only if it is shown (never navigates back)
  qa/emulator/ui.py key <KEYCODE>        # send a keyevent (4 = BACK: navigates if no keyboard!)
  qa/emulator/ui.py swipe up|down        # scroll the page
  qa/emulator/ui.py shot <name>          # screenshot to $QA_SHOTS (default /tmp/asset-tuner-qa/shots)
  qa/emulator/ui.py net on|off           # toggle wifi + mobile data
  qa/emulator/ui.py logs [pattern]       # recent flutter log lines (ANSI stripped)

Gotchas learned in the first run:
  - Tapping the center of a card can miss its inner button; tap the button coordinates instead.
  - Buttons below the fold or under the keyboard: `hidekb`, then `swipe up`, then `dump` again.
  - `key 4` with the keyboard already hidden sends the app to the background.
"""
import os
import re
import subprocess
import sys
import time
import xml.etree.ElementTree as ET

ADB = os.environ.get('ADB', os.path.expanduser('~/Library/Android/sdk/platform-tools/adb'))
SHOTS = os.environ.get('QA_SHOTS', '/tmp/asset-tuner-qa/shots')


def adb(*args):
    return subprocess.run([ADB, *args], capture_output=True, text=True).stdout


def nodes():
    xml = ''
    for _ in range(3):
        adb('shell', 'uiautomator', 'dump', '/sdcard/ui.xml')
        xml = adb('shell', 'cat', '/sdcard/ui.xml')
        if '<hierarchy' in xml:
            break
        time.sleep(1)
    root = ET.fromstring(xml[xml.index('<hierarchy'):])
    result = []
    for n in root.iter('node'):
        label = (n.get('text') or '') or (n.get('content-desc') or '')
        b = re.findall(r'\d+', n.get('bounds', ''))
        if not b:
            continue
        x1, y1, x2, y2 = map(int, b)
        result.append({
            'label': label.replace('\n', ' | '),
            'cls': n.get('class', '').split('.')[-1],
            'click': n.get('clickable') == 'true',
            'focused': n.get('focused') == 'true',
            'cx': (x1 + x2) // 2,
            'cy': (y1 + y2) // 2,
        })
    return result


def keyboard_shown():
    return 'mInputShown=true' in adb('shell', 'dumpsys', 'input_method')


def main():
    cmd, args = sys.argv[1], sys.argv[2:]
    if cmd == 'dump':
        for n in nodes():
            if n['label'] or n['click'] or n['cls'] == 'EditText':
                flag = ('C' if n['click'] else ' ') + ('F' if n['focused'] else ' ')
                print(f"{flag} {n['cls']:<14} ({n['cx']},{n['cy']}) {n['label'][:110]}")
    elif cmd == 'tap':
        idx = int(args[1]) if len(args) > 1 else 0
        matches = [n for n in nodes() if args[0].lower() in n['label'].lower()]
        if len(matches) <= idx:
            print(f'NOT FOUND: {args[0]}')
            sys.exit(1)
        n = matches[idx]
        adb('shell', 'input', 'tap', str(n['cx']), str(n['cy']))
        print(f"tapped '{n['label'][:60]}' at ({n['cx']},{n['cy']})")
    elif cmd == 'xy':
        adb('shell', 'input', 'tap', args[0], args[1])
    elif cmd == 'type':
        adb('shell', 'input', 'text', args[0].replace(' ', '%s'))
    elif cmd == 'clear':
        count = int(args[0]) if args else 40
        adb('shell', 'input', 'keyevent', '123')
        adb('shell', 'input', 'keyevent', *(['67'] * count))
    elif cmd == 'hidekb':
        if keyboard_shown():
            adb('shell', 'input', 'keyevent', '4')
            time.sleep(0.5)
    elif cmd == 'key':
        adb('shell', 'input', 'keyevent', args[0])
    elif cmd == 'swipe':
        y1, y2 = ('1900', '500') if args[0] == 'up' else ('700', '1600')
        adb('shell', 'input', 'swipe', '540', y1, '540', y2, '250')
    elif cmd == 'shot':
        os.makedirs(SHOTS, exist_ok=True)
        path = f'{SHOTS}/{args[0]}.png'
        with open(path, 'wb') as f:
            f.write(subprocess.run([ADB, 'exec-out', 'screencap', '-p'], capture_output=True).stdout)
        print(path)
    elif cmd == 'net':
        state = 'enable' if args[0] == 'on' else 'disable'
        adb('shell', 'svc', 'wifi', state)
        adb('shell', 'svc', 'data', state)
    elif cmd == 'logs':
        out = adb('logcat', '-d', '-t', '2000')
        lines = [re.sub(r'\x1b\[[0-9;]*m', '', line) for line in out.splitlines() if ' flutter ' in line]
        lines = [line for line in lines if '┄' not in line and '──' not in line]
        if args:
            lines = [line for line in lines if re.search(args[0], line, re.I)]
        print('\n'.join(lines[-40:]))
    else:
        print(__doc__)
        sys.exit(2)


if __name__ == '__main__':
    main()
