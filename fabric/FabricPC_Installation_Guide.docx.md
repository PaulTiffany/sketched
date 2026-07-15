**FabricPC Installation Guide**

*A beginner-friendly, step-by-step setup guide for Python 3.10 and FabricPC on Windows, macOS, and Linux.*

**💡 Do you need GPU support?**

WSL (Windows Subsystem for Linux) is only required if you want GPU acceleration on Windows. FabricPC's engine (JAX) only publishes GPU-ready packages for Linux.

# **Part 1 — Install Python 3.10 & pip**

Pick the section below that matches your operating system. If you're not sure, macOS and native Windows users should almost always use the CPU-only sections.

## **1\. Windows with WSL2  (for GPU support)**

1. Open PowerShell as an Administrator and run:

wsl \--install

2. Restart your PC to finish installation. Set up your Ubuntu username and password when prompted.

3. Open your new WSL/Ubuntu terminal and update your system, then install Python 3.10:

sudo apt update && sudo apt upgrade \-y  
sudo apt install python3.10 python3.10-venv python3.10-dev \-y

4. Verify the installation and install pip:

python3.10 \--version  
python3.10 \-m ensurepip \--default-pip

## **2\. Native macOS**

macOS runs Python 3.10 natively on both Intel and Apple Silicon (M1/M2/M3/M4) chips.

1. Install Homebrew if you don't already have it (run in Terminal):

/bin/bash \-c "$(curl \-fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

2. Install Python 3.10:

brew install python@3.10

3. Verify the installation and confirm pip is set up:

python3.10 \--version  
python3.10 \-m pip \--version

## **3\. Native Linux (Ubuntu / Debian)**

1. Install Python 3.10:

sudo apt update  
sudo apt install python3.10 python3.10-venv python3.10-dev \-y

2. Verify the installation and bootstrap pip:

python3.10 \--version  
python3.10 \-m ensurepip \--default-pip

## **4\. Native Windows  (CPU-only)**

Use this track if you don't need GPU acceleration.

1. Download and run the Python 3.10 installer from python.org/downloads.

2. Important: check the box labeled "Add Python 3.10 to PATH" before clicking Install.

3. Open PowerShell or Command Prompt and verify the installation:

py \-3.10 \--version

*On native Windows, pip is bundled and installed automatically.*

# **Part 2 — Install FabricPC**

Once Python 3.10 and pip are ready, follow these steps (they're the same across platforms unless noted).

## **Step 1 — Clone the repository**

Make sure git is installed, then clone the project and move into its folder:

git clone https://github.com/trueagi-io/FabricPC.git  
cd FabricPC

*On native Windows, run the same two commands in PowerShell.*

## **Step 2 — Create and activate a virtual environment**

\# macOS / Linux / WSL:  
python3.10 \-m venv venv  
source venv/bin/activate  
\# Native Windows (PowerShell):  
py \-3.10 \-m venv venv  
.\\venv\\Scripts\\Activate.ps1

## **Step 3 — Install FabricPC for your hardware**

### **GPU acceleration (NVIDIA GPU on Linux or WSL2 only)**

Check your CUDA version first:

nvidia-smi  
Then install the matching backend:

\# For CUDA 12:  
pip install \-U \-e ".\[all,cuda12\]"  
   
\# For CUDA 13:  
pip install \-U \-e ".\[all,cuda13\]"

### **Note: If you get a memory/cache error in WSL, try running the following command.**

 mkdir \-p ./tmp && TMPDIR=./tmp pip install \--no-cache-dir \-e ".\[all,cuda12\]"

### **CPU-only (native Windows, macOS, or non-GPU Linux)**

pip install \-U \-e ".\[all\]"

## **Step 4 — Run the demo**

Set up the pre-commit hooks and run the MNIST demo to confirm everything works:

pre-commit install  
python examples/mnist\_demo.py

# **Quick Reference**

| Item | Detail |
| :---- | :---- |
| Python versions supported | 3.10 – 3.13 (this guide uses 3.10 and recommends 3.10 as it does not have any dependency issues.) |
| Optional Aim tracker (\[viz\]/\[all\]) | Fully supported on Python 3.10 |
| GPU acceleration | Linux only (including WSL2) |
| Native Windows / macOS | CPU-only JAX execution |

*Source: FabricPC repository README (github.com/trueagi-io/FabricPC)*