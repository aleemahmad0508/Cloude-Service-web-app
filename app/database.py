import os
import psycopg2
from psycopg2.extras import RealDictCursor
from dotenv import load_dotenv

load_dotenv()

def get_connection():
    """
        Create a connection to the PostgreSQL database.
        Database details are read from environment variables.
    """

    connection = psycopg2.connect(
        host=os.getenv("DB_HOST"),
        port=os.getenv("DB_PORT", "5432"),
        database=os.getenv("DB_NAME"),
        user=os.getenv("DB_USER"),
        password=os.getenv("DB_PASSWORD")
    )

    return connection

def init_db():
    """
    Create the notes table if it does not already exist.
    """

    connection = get_connection()

    try:
        with connection.cursor() as cursor:
            cursor.execute("""
                CREATE TABLE IF NOT EXISTS notes (
                    id SERIAL PRIMARY KEY,
                    content TEXT NOT NULL,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                );
            """)

        connection.commit()

    finally:
        connection.close()

def get_notes():
    """
    Retrieve all notes from the database.
    """

    connection = get_connection()

    try:
        with connection.cursor(cursor_factory=RealDictCursor) as cursor:
            cursor.execute("""
                SELECT id, content, created_at
                FROM notes
                ORDER BY created_at DESC;
            """)

            return cursor.fetchall()

    finally:
        connection.close()

def add_note(content):
    """
    Add a new note to the database.
    """

    connection = get_connection()

    try:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                INSERT INTO notes (content)
                VALUES (%s);
                """,
                (content,)
            )

        connection.commit()

    finally:
        connection.close()

def delete_note(note_id):
    """
    Delete a note using its ID.
    """

    connection = get_connection()

    try:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                DELETE FROM notes
                WHERE id = %s;
                """,
                (note_id,)
            )

        connection.commit()

    finally:
        connection.close()