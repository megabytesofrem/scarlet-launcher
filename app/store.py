import sqlite3

def create_db_if_needed():
    # Create the database and the tables if they don't already exist

    con = sqlite3.connect("managed_games.db")
    cur = con.cursor()
    cur.execute("""
        CREATE TABLE IF NOT EXISTS managed_games (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            source TEXT NOT NULL,   -- 'thcrap' for thcrap managed or 'manual' if you have your own patches outside of thcrap
            name TEXT NOT NULL UNIQUE,
            path TEXT NOT NULL
        )
    """)
    con.commit()
    con.close()

def filter_game_list(game_list, source=None):
    # Filter the game list based on the source
    if source:
        game_list = [game for game in game_list if game[1] == source]
    return game_list

def add_game_to_db(source, name, path):
    # Add a new game to the SQLite database
    con = sqlite3.connect("managed_games.db")
    cur = con.cursor()
    cur.execute("""
        INSERT INTO managed_games (source, name, path)
        VALUES (?, ?, ?)
        ON CONFLICT(name) DO NOTHING;
    """, (source, name, path))
    con.commit()
    con.close()

def remove_game_from_db(name):
    # Remove a game from the SQLite database by name
    con = sqlite3.connect("managed_games.db")
    cur = con.cursor()
    cur.execute("""
        DELETE FROM managed_games
        WHERE name = ?;
    """, (name,))
    con.commit()
    con.close()

def get_game_from_db(name):
    # Get a game from the SQLite database by name
    con = sqlite3.connect("managed_games.db")
    cur = con.cursor()
    cur.execute("""
        SELECT * FROM managed_games
        WHERE name = ?;
    """, (name,))
    game = cur.fetchone()
    con.close()
    return game

def load_saved_game_list():
    # Load the saved game list from the SQLite database
    con = sqlite3.connect("managed_games.db")
    cur = con.cursor()
    cur.execute("SELECT * FROM managed_games")
    rows = cur.fetchall()
    con.close()

    return rows