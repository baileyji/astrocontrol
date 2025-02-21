FROM ubuntu:24.04

# Set non-interactive mode
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt update && apt install -y \
    curl \
    git \
    wget \
    nano \
    tmux \
    htop \
    python3-pip \
    python3-venv \
    python3-dev \
    build-essential \
    libffi-dev \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Miniforge3 and create Mamba environment
RUN curl -L -o Miniforge3.sh https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-aarch64.sh && \
    bash Miniforge3.sh -b -p /opt/conda && \
    rm Miniforge3.sh

ENV PATH="/opt/conda/bin:$PATH"

#TODO externalize the list of packages to a toml or other file driven by the control package using the container
RUN mamba create -y -n lris2csu python=3.12 numpy scipy flask zmq astropy pysoem

# Expose Jupyter Notebook and daemon process ports
EXPOSE 8888 5000

# Create directories for externally mounted scripts and app code
RUN mkdir -p /opt/app /opt/scripts

# Set startup script path
ENV STARTUP_SCRIPT=/opt/scripts/startup.sh

# Ensure startup script has execute permissions
RUN touch $STARTUP_SCRIPT && chmod +x $STARTUP_SCRIPT

# Set up volumes for external script and application code
VOLUME ["/opt/app", "/opt/scripts"]

# Entry point for the container
CMD ["/bin/bash", "$STARTUP_SCRIPT"]
