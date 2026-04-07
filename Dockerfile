FROM runpod/worker-comfyui:5.5.1-base

# This image relies on the queue handler already bundled in the worker-comfyui base image.
# We only add the workflow-specific custom nodes and model files detected from the workflow.

# Custom nodes detected from the workflow:
# - rgthree-comfy (Power Lora Loader (rgthree))
# - JPS Custom Nodes for ComfyUI (SDXL Resolutions (JPS))
# - Comfy-WaveSpeed (EnhancedLoadDiffusionModel)

WORKDIR /comfyui/custom_nodes

RUN git clone --depth 1 https://github.com/rgthree/rgthree-comfy.git
RUN git clone --depth 1 https://github.com/JPS-GER/ComfyUI_JPS-Nodes.git
RUN git clone --depth 1 https://github.com/chengzeyi/Comfy-WaveSpeed.git

# Install Python dependencies for custom nodes when present.
RUN if [ -f /comfyui/custom_nodes/rgthree-comfy/requirements.txt ]; then pip install --no-cache-dir -r /comfyui/custom_nodes/rgthree-comfy/requirements.txt; fi
RUN if [ -f /comfyui/custom_nodes/ComfyUI_JPS-Nodes/requirements.txt ]; then pip install --no-cache-dir -r /comfyui/custom_nodes/ComfyUI_JPS-Nodes/requirements.txt; fi
RUN if [ -f /comfyui/custom_nodes/Comfy-WaveSpeed/requirements.txt ]; then pip install --no-cache-dir -r /comfyui/custom_nodes/Comfy-WaveSpeed/requirements.txt; fi

WORKDIR /comfyui

# Models detected from the workflow.
# Note: the workflow contains an rgthree Power Lora node, but the LoRA entry is disabled (`on: false`),
# so no LoRA file is required for the graph to execute as exported.
RUN comfy model download --url https://huggingface.co/black-forest-labs/FLUX.1-schnell/resolve/main/ae.safetensors --relative-path models/vae --filename ae.safetensors
RUN comfy model download --url https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp16.safetensors --relative-path models/text_encoders --filename t5xxl_fp16.safetensors
RUN comfy model download --url https://huggingface.co/Comfy-Org/stable-diffusion-3.5-fp8/resolve/main/text_encoders/clip_l.safetensors --relative-path models/clip --filename clip_l.safetensors
RUN comfy model download --url https://huggingface.co/Comfy-Org/flux1-dev/resolve/main/flux1-dev-fp8.safetensors --relative-path models/diffusion_models --filename flux1-dev.safetensors

# If you later enable the currently-disabled LoRA in the workflow, add it here with the exact filename:
# RUN comfy model download --url <DIRECT_URL_TO_LORA> --relative-path "models/loras/Flux" --filename "Digital_Impressionist.safetensors"
