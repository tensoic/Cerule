#!/bin/bash
MODEL_TYPE=gemma

PRETRAIN_DIR=cerule-$MODEL_TYPE-pretrain
OUTPUT_DIR=cerule-$MODEL_TYPE
mkdir -p ./checkpoints-$MODEL_TYPE/$OUTPUT_DIR

deepspeed cerule/train/train.py \
    --deepspeed ./script/deepspeed/zero3.json \
    --model_name_or_path google/gemma-2b \
    --model_type $MODEL_TYPE \
    --version gemma_instruct \
    --data_path /finetune/bunny_695k.json \
    --image_folder /finetune/images \
    --vision_tower google/siglip-so400m-patch14-384 \
    --pretrain_mm_mlp_adapter path/to/mm_projector.bin \
    --mm_projector_type mlp2x_gelu \
    --image_aspect_ratio pad \
    --mm_vision_select_layer -2 \
    --group_by_modality_length True \
    --mm_use_im_start_end False \
    --mm_use_im_patch_token False \
    --bf16 True \
    --output_dir ./checkpoints-$MODEL_TYPE/$OUTPUT_DIR \
    --num_train_epochs 1 \
    --per_device_train_batch_size 8 \
    --per_device_eval_batch_size 4 \
    --gradient_accumulation_steps 2 \
    --evaluation_strategy "no" \
    --save_strategy "steps" \
    --save_steps 500 \
    --save_total_limit 1 \
    --learning_rate 2e-5 \
    --weight_decay 0. \
    --warmup_ratio 0.03 \
    --lr_scheduler_type "cosine" \
    --logging_steps 1 \
    --tf32 True \
    --model_max_length 2048 \
    --gradient_checkpointing True \
    --dataloader_num_workers 4 \
    --lazy_preprocess True \
    --report_to wandb | tee 2>&1 ./checkpoints-$MODEL_TYPE/$OUTPUT_DIR/log.txt
