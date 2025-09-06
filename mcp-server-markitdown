# api_server.py
import os
import uuid
import subprocess
from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.responses import Response

app = FastAPI()

@app.post("/convert")
async def convert_document(file: UploadFile = File(...)):
    if not file.filename.endswith(".docx"):
        raise HTTPException(status_code=400, detail="Por favor, envie um arquivo .docx")

    temp_id = str(uuid.uuid4())
    input_path = f"/tmp/{temp_id}.docx"
    output_path = f"/tmp/{temp_id}.md"

    try:
        with open(input_path, "wb") as buffer:
            buffer.write(await file.read())

        # O 'ENTRYPOINT' original era "markitdown", então ele está no PATH.
        # Podemos chamá-lo diretamente.
        command = [
            "markitdown",
            "--input",
            input_path,
            "--output",
            output_path,
        ]
        result = subprocess.run(
            command, capture_output=True, text=True, check=True
        )

        with open(output_path, "r", encoding="utf-8") as md_file:
            markdown_content = md_file.read()

        return Response(content=markdown_content, media_type="text/markdown")

    except subprocess.CalledProcessError as e:
        error_details = e.stderr or e.stdout
        raise HTTPException(
            status_code=500,
            detail=f"Falha na conversão do arquivo: {error_details}",
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Um erro inesperado ocorreu: {str(e)}")

    finally:
        if os.path.exists(input_path):
            os.remove(input_path)
        if os.path.exists(output_path):
            os.remove(output_path)
