# Use NVIDIA PyTorch base image with CUDA support
FROM nvcr.io/nvidia/pytorch:23.12-py3

# Set working directory
WORKDIR /workspace

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    git-lfs \
    wget \
    curl \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Git LFS
RUN git lfs install

# Clone TensorRT repository with SVD support
RUN git clone https://github.com/rajeevsrao/TensorRT.git && \
    cd TensorRT && \
    git checkout release/svd

# Set environment variables for CUDA and TensorRT
ENV CUDA_HOME=/usr/local/cuda
ENV PATH=${CUDA_HOME}/bin:${PATH}
ENV LD_LIBRARY_PATH=${CUDA_HOME}/lib64:${LD_LIBRARY_PATH}
ENV TORCH_CUDA_ARCH_LIST="8.6"

# Install Python dependencies
COPY requirements.txt .
RUN pip install --upgrade pip
RUN pip install -r requirements.txt

# Install TensorRT from NVIDIA PyPI
RUN pip install --pre --upgrade --extra-index-url https://pypi.nvidia.com tensorrt

# Create directories for models and engines
RUN mkdir -p /workspace/models /workspace/engines /workspace/output

# Copy application files
COPY . /workspace/

# Set permissions
RUN chmod +x /workspace/run_svd.sh

# Default command
CMD ["/bin/bash"]
