# MANTIDO - Mesma imagem base
FROM python:3.13-slim-bullseye

# MANTIDO - Variáveis de ambiente e dependências do sistema
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

# MANTIDO - Diretório de trabalho e cópia do código
WORKDIR /app
COPY . /app

# MANTIDO - Instalação do markitdown e seus plugins
RUN pip --no-cache-dir install \
    /app/packages/markitdown[all] \
    /app/packages/markitdown-sample-plugin

# ADICIONADO - Instalação das dependências do nosso servidor web
RUN pip --no-cache-dir install fastapi uvicorn python-multipart

# MANTIDO - Prática de segurança para rodar como usuário não-root
ARG USERID=nobody
ARG GROUPID=nogroup
USER $USERID:$GROUPID

# ALTERADO - O comando de execução final.
# Em vez de iniciar o CLI 'markitdown', iniciamos nosso servidor web 'uvicorn'.
# O servidor executará o arquivo 'api_server.py' e a aplicação 'app' contida nele.
CMD ["uvicorn", "api_server:app", "--host", "0.0.0.0", "--port", "8000"]

# REMOVIDO - O ENTRYPOINT original é substituído pelo CMD acima.
# ENTRYPOINT [ "markitdown" ]
