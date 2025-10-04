#!/bin/bash

# Stable Video Diffusion TensorRT Runner Script
# Optimized for NVIDIA RTX 3090

set -e

# Configuration
MODEL_NAME="stabilityai/stable-video-diffusion-img2vid-xt-1-1-tensorrt"
TENSORRT_DIR="/workspace/TensorRT"
DEMO_DIR="${TENSORRT_DIR}/demo/Diffusion"
ENGINE_DIR="/workspace/engines/svd-xt-1-1"
ONNX_DIR="/workspace/models/${MODEL_NAME}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Stable Video Diffusion TensorRT Setup ===${NC}"

# Function to check if GPU is available
check_gpu() {
    echo -e "${YELLOW}Checking GPU availability...${NC}"
    if nvidia-smi > /dev/null 2>&1; then
        echo -e "${GREEN}✓ GPU detected:${NC}"
        nvidia-smi --query-gpu=name,memory.total,memory.used --format=csv,noheader,nounits
    else
        echo -e "${RED}✗ No GPU detected or NVIDIA drivers not available${NC}"
        exit 1
    fi
}

# Function to setup Hugging Face authentication
setup_hf_auth() {
    echo -e "${YELLOW}Setting up Hugging Face authentication...${NC}"
    if [ ! -f ~/.cache/huggingface/token ]; then
        echo -e "${BLUE}Please login to Hugging Face:${NC}"
        huggingface-cli login
    else
        echo -e "${GREEN}✓ Hugging Face token found${NC}"
    fi
}

# Function to download model
download_model() {
    echo -e "${YELLOW}Downloading Stable Video Diffusion model...${NC}"
    mkdir -p /workspace/models
    cd /workspace/models
    
    if [ ! -d "${MODEL_NAME}" ]; then
        echo -e "${BLUE}Cloning model repository...${NC}"
        git lfs install
        git clone "https://huggingface.co/${MODEL_NAME}"
    else
        echo -e "${GREEN}✓ Model already downloaded${NC}"
    fi
}

# Function to setup TensorRT environment
setup_tensorrt() {
    echo -e "${YELLOW}Setting up TensorRT environment...${NC}"
    
    if [ ! -d "${TENSORRT_DIR}" ]; then
        echo -e "${BLUE}Cloning TensorRT repository...${NC}"
        cd /workspace
        git clone https://github.com/rajeevsrao/TensorRT.git
        cd TensorRT
        git checkout release/svd
    else
        echo -e "${GREEN}✓ TensorRT repository found${NC}"
    fi
    
    # Install dependencies
    cd "${DEMO_DIR}"
    pip install -r requirements.txt
}

# Function to build TensorRT engine
build_engine() {
    echo -e "${YELLOW}Building TensorRT engine for RTX 3090...${NC}"
    
    mkdir -p "${ENGINE_DIR}"
    
    cd "${DEMO_DIR}"
    
    python3 demo_img2vid.py \
        --version svd-xt-1.1 \
        --onnx-dir "${ONNX_DIR}" \
        --engine-dir "${ENGINE_DIR}" \
        --build-static-batch \
        --use-cuda-graph \
        --fp16 \
        --verbose
}

# Function to run inference
run_inference() {
    local input_image="$1"
    local output_dir="$2"
    
    if [ -z "$input_image" ]; then
        input_image="https://www.hdcarwallpapers.com/walls/2018_chevrolet_camaro_zl1_nascar_race_car_2-HD.jpg"
        echo -e "${YELLOW}No input image provided, using default: ${input_image}${NC}"
    fi
    
    if [ -z "$output_dir" ]; then
        output_dir="/workspace/output"
    fi
    
    mkdir -p "${output_dir}"
    
    echo -e "${YELLOW}Running inference...${NC}"
    echo -e "${BLUE}Input image: ${input_image}${NC}"
    echo -e "${BLUE}Output directory: ${output_dir}${NC}"
    
    cd "${DEMO_DIR}"
    
    python3 demo_img2vid.py \
        --version svd-xt-1.1 \
        --onnx-dir "${ONNX_DIR}" \
        --engine-dir "${ENGINE_DIR}" \
        --input-image "${input_image}" \
        --output-dir "${output_dir}" \
        --use-cuda-graph \
        --fp16 \
        --num-frames 25 \
        --fps 6 \
        --verbose
}

# Main execution
case "$1" in
    "setup")
        check_gpu
        setup_hf_auth
        download_model
        setup_tensorrt
        echo -e "${GREEN}✓ Setup complete! Run './run_svd.sh build' to build the engine${NC}"
        ;;
    "build")
        build_engine
        echo -e "${GREEN}✓ Engine built successfully!${NC}"
        ;;
    "run")
        run_inference "$2" "$3"
        echo -e "${GREEN}✓ Inference complete! Check output directory${NC}"
        ;;
    "full")
        check_gpu
        setup_hf_auth
        download_model
        setup_tensorrt
        build_engine
        run_inference "$2" "$3"
        ;;
    *)
        echo -e "${BLUE}Usage: $0 {setup|build|run|full} [input_image] [output_dir]${NC}"
        echo -e "${YELLOW}Commands:${NC}"
        echo -e "  setup  - Download model and setup environment"
        echo -e "  build  - Build TensorRT engine"
        echo -e "  run    - Run inference (optionally with custom input image)"
        echo -e "  full   - Complete pipeline (setup + build + run)"
        echo -e ""
        echo -e "${YELLOW}Examples:${NC}"
        echo -e "  $0 setup"
        echo -e "  $0 build"
        echo -e "  $0 run /path/to/image.jpg"
        echo -e "  $0 full https://example.com/image.jpg /workspace/output"
        exit 1
        ;;
esac
