# Stable Video Diffusion TensorRT Docker Setup

This repository provides a complete Docker environment for running **Stable Video Diffusion Image-to-Video XT 1.1** with TensorRT optimization on NVIDIA GPUs, specifically optimized for the RTX 3090.

## 🚀 Features

- **TensorRT Optimization**: Maximum performance with RTX 3090's 24GB VRAM
- **Docker Environment**: Isolated, reproducible setup
- **Easy Setup**: Automated model download and engine building
- **Flexible Usage**: Support for custom input images and output directories
- **GPU Acceleration**: Full CUDA support with NVIDIA Container Toolkit

## 📋 Prerequisites

### System Requirements
- **GPU**: NVIDIA RTX 3090 (24GB VRAM recommended)
- **OS**: Windows 10/11 with WSL2 or Linux
- **Docker**: Docker Desktop with GPU support
- **NVIDIA Drivers**: Latest drivers installed
- **NVIDIA Container Toolkit**: For GPU access in Docker

### Software Requirements
- Docker Desktop
- NVIDIA Container Toolkit
- Git LFS
- Hugging Face account (for model access)

## 🛠️ Installation

### 1. Install Prerequisites

#### Windows (WSL2):
```bash
# Install NVIDIA Container Toolkit
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list

sudo apt-get update && sudo apt-get install -y nvidia-docker2
sudo systemctl restart docker
```

#### Linux:
```bash
# Install NVIDIA Container Toolkit
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
  sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
  sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker
```

### 2. Clone and Setup

```bash
# Clone this repository
git clone <your-repo-url>
cd stable-video-diffusion-img2vid-xt-1-1

# Create necessary directories
mkdir -p models engines output
```

### 3. Build Docker Image

```bash
# Build the Docker image
docker-compose build
```

## 🎯 Usage

### Quick Start

```bash
# Start the container
docker-compose up -d

# Enter the container
docker-compose exec svd-tensorrt bash

# Inside the container, run the complete pipeline
./run_svd.sh full
```

### Step-by-Step Setup

#### 1. Start Container
```bash
docker-compose up -d
docker-compose exec svd-tensorrt bash
```

#### 2. Setup Environment (First time only)
```bash
./run_svd.sh setup
```

#### 3. Build TensorRT Engine (First time only)
```bash
./run_svd.sh build
```

#### 4. Run Inference
```bash
# Use default image
./run_svd.sh run

# Use custom image
./run_svd.sh run /path/to/your/image.jpg

# Use custom image and output directory
./run_svd.sh run /path/to/your/image.jpg /workspace/output/custom
```

### Command Reference

| Command | Description |
|---------|-------------|
| `./run_svd.sh setup` | Download model and setup environment |
| `./run_svd.sh build` | Build TensorRT engine (optimized for RTX 3090) |
| `./run_svd.sh run [image] [output]` | Run inference with optional custom image/output |
| `./run_svd.sh full [image] [output]` | Complete pipeline (setup + build + run) |

## 📁 Directory Structure

```
.
├── Dockerfile              # Docker configuration
├── docker-compose.yml      # Docker Compose configuration
├── requirements.txt        # Python dependencies
├── run_svd.sh             # Main execution script
├── README.md              # This file
├── models/                # Downloaded models (mounted volume)
├── engines/               # Built TensorRT engines (mounted volume)
└── output/                # Generated videos (mounted volume)
```

## ⚙️ Configuration

### Environment Variables

You can customize the setup by modifying `docker-compose.yml`:

```yaml
environment:
  - CUDA_VISIBLE_DEVICES=0        # GPU selection
  - NVIDIA_VISIBLE_DEVICES=all    # GPU visibility
```

### Performance Tuning

The script is optimized for RTX 3090 with these settings:
- **FP16 Precision**: Reduced memory usage
- **CUDA Graphs**: Faster inference
- **Static Batching**: Optimized for consistent performance
- **25 Frames**: Default video length
- **6 FPS**: Default frame rate

## 🐛 Troubleshooting

### Common Issues

#### 1. GPU Not Detected
```bash
# Check if NVIDIA drivers are working
nvidia-smi

# Verify Docker GPU support
docker run --rm --gpus all nvidia/cuda:11.8-base-ubuntu20.04 nvidia-smi
```

#### 2. Out of Memory Errors
- Ensure you have at least 20GB free VRAM
- Try reducing batch size in the script
- Close other GPU-intensive applications

#### 3. Model Download Issues
```bash
# Login to Hugging Face manually
huggingface-cli login

# Check token
cat ~/.cache/huggingface/token
```

#### 4. TensorRT Build Failures
```bash
# Check CUDA version compatibility
nvcc --version

# Verify TensorRT installation
python -c "import tensorrt; print(tensorrt.__version__)"
```

### Logs and Debugging

```bash
# View container logs
docker-compose logs svd-tensorrt

# Enter container for debugging
docker-compose exec svd-tensorrt bash

# Check GPU usage during inference
nvidia-smi -l 1
```

## 📊 Performance

### RTX 3090 Benchmarks
- **Engine Build Time**: ~15-30 minutes (first time)
- **Inference Time**: ~2-5 seconds per 25-frame video
- **Memory Usage**: ~18-22GB VRAM during inference
- **Output Quality**: 1024x576 resolution, 25 frames

### Optimization Tips
1. **Keep container running**: Avoid rebuilding engines
2. **Use SSD storage**: Faster model loading
3. **Close unnecessary applications**: Free up VRAM
4. **Batch processing**: Process multiple images sequentially

## 🔧 Advanced Usage

### Custom Model Configuration

Edit `run_svd.sh` to modify:
- Frame count (`--num-frames`)
- Frame rate (`--fps`)
- Resolution settings
- Precision mode (`--fp16`, `--fp32`)

### Web Interface (Optional)

Add Gradio interface for easier usage:

```bash
# Install additional dependencies
pip install gradio

# Run with web interface
python gradio_app.py
```

## 📝 License

This project uses the Stable Video Diffusion model from Stability AI. Please check the [model license](https://huggingface.co/stabilityai/stable-video-diffusion-img2vid-xt-1-1-tensorrt) for usage terms.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with your RTX 3090
5. Submit a pull request

## 📞 Support

For issues specific to this Docker setup, please open an issue in this repository.

For model-related questions, refer to:
- [Stable Video Diffusion Model Card](https://huggingface.co/stabilityai/stable-video-diffusion-img2vid-xt-1-1-tensorrt)
- [TensorRT Documentation](https://docs.nvidia.com/deeplearning/tensorrt/)

---

**Happy video generation! 🎬✨**
