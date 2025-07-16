# Lego coastguard server

This is a very early Proof of Concept of a server for the lego coastguard game

## Requirements

- Python 3.10
- UV
- A copy of the lego coastguard game from <https://files.maskofdestiny.com/LEGO/gms/download/City/CoastGuardGame.zip>
- A browser that supports flash player

## Setup

- Extract all of the files from the zip file (not including the root folder) into the [static](./static) directory
- Run `uv sync`

## Usage

- Run `uv run python -m flask run --debug`
- Navigate your browser to `http://localhost:5000/Launcher.html`
