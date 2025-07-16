import xml.etree.ElementTree as ET
from flask import Flask, request, redirect, make_response
import uuid

from lego_crypt import Crypt
import mln

app = Flask(__name__)

def generate_body(session_id, username):
    first_line = "<root>"
    rest = f"""<token>{session_id}</token>
    <data>
        <mylegobadge>1</mylegobadge>
        <level levelnumber="1">
            <score>0</score>
            <medals>0</medals>
        </level>
        <totalscore>0</totalscore>
        <currentrank>1</currentrank>
        <levelsunlocked>0</levelsunlocked>
        <loginurl>{mln.get_login_url(session_id)}</loginurl>
        <legowebsiteurl></legowebsiteurl>
        <getbadgeurl>{mln.MLN_MAILBOX_URL}</getbadgeurl>
    </data>
</root>
"""
    username_tag =f"<username>{username}</username>"

    if username:
        return f"{first_line}\n{username_tag}\n{rest}"
    else:
        return f"{first_line}\n{rest}"

def encrypt_body(body):
    return Crypt.f_encrypt(body, Crypt.S_ENCRYPTION_KEY1)

@app.route("/InfoRequest.xml", methods=["POST"])
def info_request():
    # All requests must have the session_id cookie
    session_id = request.cookies.get("session_id")
    if session_id is None:
        res = make_response()
        res.set_cookie("session_id", value=str(uuid.uuid4()))
        return res

    # Check if scores need to be sent to MLN
    request_body = Crypt.f_decrypt(request.form["_Body"])
    root = ET.fromstring(request_body)
    username = mln.SESSION_TO_USERNAME.get(session_id)
    method = root.attrib["method"]

    if method == "savescore" and username is not None:
        data = root.find("data")
        rank = int(data.find("currentrank").text)
        mln.submit_rank(session_id, rank)

    body = generate_body(session_id, username)
    encrypted_body = encrypt_body(body)
    return (f'''
<?xml version="1.0" encoding="utf-8"?>
<string xmlns="http://www.lego.com/Services.HiScore/service">{encrypted_body}</string>
''')

@app.route("/config.xml")
def config():
    return app.send_static_file("config.xml")

@app.route("/strings.xml")
def strings():
    return app.send_static_file("strings.xml")

@app.route("/index.html")
@app.route("/")
@app.route("/Launcher.html")
def launcher():
    return app.send_static_file("Launcher.html")

@app.route("/LegoCoastGuards.swf")
def legocoastguards():
    return app.send_static_file("LegoCoastGuards.swf")

@app.route("/loader.swf")
def loader():
    return app.send_static_file("loader.swf")

@app.route("/icon")
def icon():
    return app.send_static_file("icon.png")

@app.route("/api/login")
def on_mln_login():
    mln.on_login(**request.args)
    return redirect("/")
