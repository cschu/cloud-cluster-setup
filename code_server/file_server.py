from flask import Flask, render_template_string, request
import os
import pygments
from pygments.lexers import PythonLexer
from pygments.formatters import HtmlFormatter

app = Flask(__name__)

TEMPLATE_LIST = """
<!DOCTYPE html>
<html>
<head>
    <title>Python File Browser</title>
</head>
<body>
    <h1>Python Files in Directory</h1>
    <ul>
        {% for file in files %}
            <li><a href="/view?file={{ file }}">{{ file }}</a></li>
        {% endfor %}
    </ul>
</body>
</html>
"""

TEMPLATE_VIEW = """
<!DOCTYPE html>
<html>
<head>
    <title>Viewing: {{ filename }}</title>
    <style>{{ style }}</style>
</head>
<body>
    <h1>Viewing: {{ filename }}</h1>
    <pre>{{ content|safe }}</pre>
    <p><a href="/">Back to list</a></p>
</body>
</html>
"""

EXTENSIONS_TO_SHOW = (
    ".json",
    ".nf",
    ".py",
)


def files_to_show(fname):
    for end in EXTENSIONS_TO_SHOW:
        if fname.endswith(end):
            return True
    return False


@app.route("/")
def file_list():

    files = filter(files_to_show, os.listdir("."))
    return render_template_string(TEMPLATE_LIST, files=files)


@app.route("/view")
def view_file():
    filename = request.args.get("file")
    files = filter(files_to_show, os.listdir("."))
    content = None
    style = HtmlFormatter().get_style_defs(".highlight")

    if filename and filename in files:
        with open(filename, "r", encoding="utf-8") as f:
            code = f.read()
            content = pygments.highlight(code, PythonLexer(), HtmlFormatter())

    return render_template_string(
        TEMPLATE_VIEW, filename=filename, content=content, style=style
    )


if __name__ == "__main__":
    # Run on port 80 (needs to run as root)
    # Port 80 was used because we couldn't open ports 8000 or 8080 in OpenStack
    app.run(host="0.0.0.0", port=80)
