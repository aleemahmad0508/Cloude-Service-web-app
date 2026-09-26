import os

import boto3
from flask import Flask, render_template, request, redirect, url_for

from database import init_db, get_notes, add_note, delete_note

app = Flask(__name__)

# --------------------------------------------------
# AWS S3 configuration
# --------------------------------------------------

S3_BUCKET_NAME = os.environ.get("S3_BUCKET_NAME")

s3 = boto3.client("s3")


# --------------------------------------------------
# Home page
# --------------------------------------------------

@app.route("/")
def home():
    """
    Get notes from PostgreSQL and display them.
    """

    notes = get_notes()

    return render_template("index.html", notes=notes)


# --------------------------------------------------
# Add note + upload file
# --------------------------------------------------

@app.route("/add", methods=["POST"])
def create_note():
    """
    Receive a note and optional file.

    Note  -> PostgreSQL
    File  -> Amazon S3
    """

    note = request.form.get("note")
    file = request.files.get("file")

    if note and note.strip():

        # Save note in PostgreSQL
        add_note(note.strip())

        # Upload file to S3 if user selected one
        if file and file.filename:

            s3.upload_fileobj(
                file,
                S3_BUCKET_NAME,
                f"uploads/{file.filename}"
            )

    return redirect(url_for("home"))


# --------------------------------------------------
# Delete note
# --------------------------------------------------

@app.route("/delete/<int:note_id>", methods=["POST"])
def remove_note(note_id):
    """
    Delete a note from PostgreSQL.
    """

    delete_note(note_id)

    return redirect(url_for("home"))


# --------------------------------------------------
# Health check
# --------------------------------------------------

@app.route("/health")
def health():
    return {
        "status": "healthy",
        "application": "Cloud Notes App"
    }


# --------------------------------------------------
# Application startup
# --------------------------------------------------

if __name__ == "__main__":

    # Create the database table when the application starts.
    init_db()

    app.run(
        host="0.0.0.0",
        port=5000,
        debug=True
    )