#!/usr/bin/env python3
import sys
import xml.etree.ElementTree as ET
from html import escape
from pathlib import Path
from collections import defaultdict, Counter


def parse_junit_style(root):
    """
    Parsea archivos JUnit donde la raíz puede ser <testsuite>
    o <testsuites><testsuite>...</testsuite></testsuites>.
    Devuelve una lista de dicts con info de cada testcase.
    """
    test_cases = []

    # 1) Construir lista de suites
    suites = []

    if root.tag == "testsuite":
        suites.append(root)

    suites.extend(root.findall(".//testsuite"))
    # eliminar duplicados manteniendo orden
    suites = list(dict.fromkeys(suites))

    # 2) Recorrer suites y testcases
    for ts in suites:
        suite_name = ts.get("name", "suite")

        for tc in ts.findall("testcase"):
            name = tc.get("name", "test")
            classname = tc.get("classname", suite_name)
            time = tc.get("time", "0")
            raw_status = (tc.get("status", "") or "").upper()

            # Normalizar status
            if raw_status in ("RUN", "", "PASSED", "PASS"):
                status = "PASS"
            elif raw_status in ("FAILED", "FAIL"):
                status = "FAIL"
            elif raw_status in ("SKIPPED", "DISABLED", "NOTRUN"):
                status = "SKIP"
            else:
                status = raw_status or "UNKNOWN"

            message = ""
            failure = tc.find("failure")
            error = tc.find("error")
            skipped = tc.find("skipped")

            if failure is not None:
                status = "FAIL"
                message = failure.get("message", "") or (failure.text or "")
            elif error is not None:
                status = "ERROR"
                message = error.get("message", "") or (error.text or "")
            elif skipped is not None:
                status = "SKIP"
                message = skipped.get("message", "") or (skipped.text or "")

            # system-out como salida de “terminal”
            sysout = tc.findtext("system-out", default="")
            sysout = sysout.rstrip("\n")

            test_cases.append(
                {
                    "suite": suite_name,
                    "name": name,
                    "classname": classname,
                    "time": time,
                    "status": status,
                    "message": (message or "").strip(),
                    "sysout": sysout,
                }
            )

    return test_cases


def render_html(test_cases, junit_file: Path, output_path: Path):
    output_path.parent.mkdir(parents=True, exist_ok=True)

    # Agrupar por suite
    suites = defaultdict(list)
    for tc in test_cases:
        suites[tc["suite"]].append(tc)

    html = [
        "<!DOCTYPE html>",
        "<html lang='es'>",
        "<head>",
        "  <meta charset='utf-8' />",
        "  <title>Reporte de tests</title>",
        "  <style>",
        "    body { font-family: system-ui, -apple-system, BlinkMacSystemFont, sans-serif;",
        "           margin: 2rem; background: #fafafa; }",
        "    h1 { margin-bottom: 0.2rem; }",
        "    p.meta { color: #666; font-size: 0.9rem; margin-top: 0; }",
        "",
        "    details.suite {",
        "      border: 1px solid #ddd;",
        "      border-radius: 8px;",
        "      background: #fff;",
        "      margin-top: 1rem;",
        "      box-shadow: 0 1px 2px rgba(0,0,0,0.04);",
        "    }",
        "    details.suite > summary {",
        "      padding: 0.6rem 0.8rem;",
        "      cursor: pointer;",
        "      font-weight: 600;",
        "      display: flex;",
        "      align-items: baseline;",
        "      gap: 0.75rem;",
        "      list-style: none;",
        "    }",
        "    details.suite[open] > summary {",
        "      border-bottom: 1px solid #eee;",
        "      background: #f8f8f8;",
        "    }",
        "    details.suite > summary::-webkit-details-marker { display: none; }",
        "",
        "    .suite-name { font-size: 1rem; }",
        "    .suite-meta { font-size: 0.8rem; color: #666; }",
        "",
        "    .badge {",
        "      display: inline-block;",
        "      padding: 0.1rem 0.5rem;",
        "      border-radius: 999px;",
        "      font-size: 0.7rem;",
        "      text-transform: uppercase;",
        "      letter-spacing: 0.04em;",
        "      background: #eee;",
        "      color: #555;",
        "    }",
        "    .badge-pass { background: #e6f6ea; color: #137333; }",
        "    .badge-fail { background: #fde7e9; color: #b3261e; }",
        "    .badge-skip { background: #f5f5f5; color: #666; }",
        "",
        "    details.test {",
        "      border-top: 1px solid #eee;",
        "    }",
        "    details.test > summary {",
        "      padding: 0.5rem 0.9rem;",
        "      cursor: pointer;",
        "      display: flex;",
        "      align-items: center;",
        "      gap: 0.75rem;",
        "      font-size: 0.9rem;",
        "      list-style: none;",
        "    }",
        "    details.test > summary::-webkit-details-marker { display: none; }",
        "",
        "    .test-name { font-weight: 500; }",
        "    .test-time { margin-left: auto; font-size: 0.8rem; color: #666; }",
        "",
        "    .test-body {",
        "      padding: 0 1rem 0.8rem 1.4rem;",
        "      font-size: 0.85rem;",
        "    }",
        "    .test-body p { margin: 0.25rem 0; }",
        "    .label { font-weight: 600; }",
        "",
        "    pre.terminal {",
        "      background: #111;",
        "      color: #eee;",
        "      padding: 0.6rem 0.8rem;",
        "      border-radius: 6px;",
        "      margin-top: 0.4rem;",
        "      overflow-x: auto;",
        "      font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas,",
        "                   'Liberation Mono', 'Courier New', monospace;",
        "      font-size: 0.8rem;",
        "      line-height: 1.35;",
        "      border: 1px solid #222;",
        "    }",
        "",
        "    .empty { color: #999; font-style: italic; }",
        "  </style>",
        "</head>",
        "<body>",
        "  <h1>Reporte de pruebas (ctest + GoogleTest)</h1>",
        f"  <p class='meta'>Fuente JUnit: {escape(str(junit_file))}</p>",
    ]

    if not test_cases:
        html += [
            "  <p class='empty'>No se encontraron pruebas en el archivo JUnit.</p>",
            "</body>",
            "</html>",
        ]
        output_path.write_text("\n".join(html), encoding="utf-8")
        return

    # Render por suite
    for suite_name, cases in suites.items():
        counts = Counter(tc["status"] for tc in cases)
        total = len(cases)
        passed = counts.get("PASS", 0)
        failed = counts.get("FAIL", 0) + counts.get("ERROR", 0)
        skipped = counts.get("SKIP", 0)

        html.append(f"<details class='suite' open>")
        html.append("  <summary>")

        html.append(f"    <span class='suite-name'>{escape(suite_name)}</span>")
        html.append(
            f"    <span class='suite-meta'>{total} tests · "
            f"{passed} pass, {failed} fail, {skipped} skip</span>"
        )

        if failed > 0:
            html.append("    <span class='badge badge-fail'>FAIL</span>")
        else:
            html.append("    <span class='badge badge-pass'>PASS</span>")

        html.append("  </summary>")

        # Tests de la suite
        for tc in cases:
            status = tc["status"]
            cls = tc["classname"]
            name = tc["name"]
            time = tc["time"]
            message = tc["message"]
            sysout = tc["sysout"]

            if status == "PASS":
                badge_class = "badge-pass"
            elif status in ("FAIL", "ERROR"):
                badge_class = "badge-fail"
            elif status == "SKIP":
                badge_class = "badge-skip"
            else:
                badge_class = ""

            html.append("<details class='test'>")
            html.append("  <summary>")
            html.append(f"    <span class='badge {badge_class}'>{status}</span>")
            html.append(f"    <span class='test-name'>{escape(name)}</span>")
            if cls and cls != name:
                html.append(f"    <span class='suite-meta'>({escape(cls)})</span>")
            html.append(f"    <span class='test-time'>{escape(str(time))} s</span>")
            html.append("  </summary>")

            html.append("  <div class='test-body'>")
            if message:
                html.append(
                    f"    <p><span class='label'>Mensaje:</span> "
                    f"{escape(message)}</p>"
                )
            else:
                html.append(
                    "    <p><span class='label'>Mensaje:</span> "
                    "<span class='empty'>(sin mensaje)</span></p>"
                )

            if sysout.strip():
                html.append("    <p><span class='label'>Output:</span></p>")
                html.append(
                    f"    <pre class='terminal'>{escape(sysout)}</pre>"
                )
            else:
                html.append(
                    "    <p><span class='label'>Output:</span> "
                    "<span class='empty'>(sin salida)</span></p>"
                )

            html.append("  </div>")
            html.append("</details>")

        html.append("</details>")

    html += [
        "</body>",
        "</html>",
    ]

    output_path.write_text("\n".join(html), encoding="utf-8")
    print(f"[render_ctest_report] HTML generado en {output_path}")


def main():
    if len(sys.argv) != 3:
        print("Uso: render_ctest_report.py <ctest.xml> <salida.html>")
        sys.exit(1)

    junit_path = Path(sys.argv[1])
    html_out = Path(sys.argv[2])

    if not junit_path.exists():
        print(f"[render_ctest_report] No se encontró {junit_path}")
        sys.exit(1)

    tree = ET.parse(junit_path)
    root = tree.getroot()

    test_cases = parse_junit_style(root)
    render_html(test_cases, junit_path, html_out)


if __name__ == "__main__":
    main()
