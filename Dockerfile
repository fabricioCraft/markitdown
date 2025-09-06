# Usa a imagem Python oficial como base
FROM python:3.13-slim-bullseye

# Mantém as variáveis e dependências originais do markitdown
ENV DEBIAN_FRONTEND=noninteractive
ENV EXIFTOOL_PATH=/usr/bin/exiftool
ENV FFMPEG_PATH=/usr/bin/ffmpeg
RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg \
    exiftool
ARG INSTALL_GIT=false
RUN if [ "$INSTALL_GIT" = "true" ]; then \
    apt-get install -y --no-install-recommends \
    git; \
    fi
RUN rm -rf /var/lib/apt/lists/*

# Define o diretório de trabalho e copia todo o código do seu repositório para dentro da imagem
WORKDIR /app
COPY . /app

# Instala o markitdown e seus plugins a partir do código que acabamos de copiar
RUN pip --no-cache-dir install \
    /app/packages/markitdown[all] \
    /app/packages/markitdown-sample-plugin

# ADICIONADO: Instala as dependências do nosso servidor web (FastAPI e Uvicorn)
RUN pip --no-cache-dir install fastapi uvicorn python-multipart

# Define os argumentos para o usuário e grupo (boa prática de segurança)
ARG USERID=nobody
ARG GROUPID=nogroup

# CORREÇÃO CRÍTICA: Antes de trocar para o usuário não-root, mudamos o proprietário
# de todos os arquivos da aplicação. Isso garante que o usuário 'nobody' terá
# permissão para ler e executar o nosso api_server.py.
RUN chown -R $USERID:$GROUPID /app

# Troca para o usuário com privilégios mínimos para executar a aplicação
USER $USERID:$GROUPID

# COMANDO FINAL: Em vez de iniciar o CLI, inicia o servidor web Uvicorn.
# Ele irá rodar o objeto 'app' de dentro do arquivo 'api_server.py'.
# '--host 0.0.0.0' torna o servidor acessível de fora do contêiner.
CMD ["uvicorn", "api_server:app", "--host", "0.0.0.0", "--port", "8000"]
