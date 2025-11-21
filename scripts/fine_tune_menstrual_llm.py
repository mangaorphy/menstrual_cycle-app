#!/usr/bin/env python3
"""
Fine-tuning Script for Menstrual Health LLM
This script helps you fine-tune models using your collected training data.
"""

import json
import os
import openai
from typing import List, Dict
import argparse

class MenstrualHealthFineTuner:
    def __init__(self, api_key: str):
        self.client = openai.OpenAI(api_key=api_key)
    
    def prepare_training_data(self, flutter_jsonl_path: str, output_path: str) -> str:
        """Convert Flutter-exported JSONL to OpenAI fine-tuning format"""
        print(f"📚 Reading training data from {flutter_jsonl_path}")
        
        training_examples = []
        
        with open(flutter_jsonl_path, 'r') as f:
            for line in f:
                data = json.loads(line.strip())
                # Data is already in OpenAI format from Flutter export
                training_examples.append(data)
        
        print(f"✅ Found {len(training_examples)} training examples")
        
        # Validate and clean data
        cleaned_examples = self.validate_training_data(training_examples)
        
        # Write cleaned data
        with open(output_path, 'w') as f:
            for example in cleaned_examples:
                f.write(json.dumps(example) + '\n')
        
        print(f"💾 Saved {len(cleaned_examples)} cleaned examples to {output_path}")
        return output_path
    
    def validate_training_data(self, examples: List[Dict]) -> List[Dict]:
        """Validate and clean training examples"""
        cleaned = []
        
        for example in examples:
            # Check required format
            if 'messages' not in example:
                continue
                
            messages = example['messages']
            if len(messages) < 2:
                continue
            
            # Ensure proper roles
            valid = True
            for msg in messages:
                if 'role' not in msg or 'content' not in msg:
                    valid = False
                    break
                if msg['role'] not in ['system', 'user', 'assistant']:
                    valid = False
                    break
            
            if valid:
                cleaned.append(example)
        
        return cleaned
    
    def upload_training_file(self, file_path: str) -> str:
        """Upload training file to OpenAI"""
        print(f"📤 Uploading training file: {file_path}")
        
        with open(file_path, 'rb') as f:
            response = self.client.files.create(
                file=f,
                purpose='fine-tune'
            )
        
        file_id = response.id
        print(f"✅ File uploaded successfully. File ID: {file_id}")
        return file_id
    
    def create_fine_tuning_job(self, file_id: str, model: str = "gpt-3.5-turbo") -> str:
        """Create a fine-tuning job"""
        print(f"🚀 Starting fine-tuning job with model: {model}")
        
        response = self.client.fine_tuning.jobs.create(
            training_file=file_id,
            model=model,
            hyperparameters={
                "n_epochs": 3,  # Start with 3 epochs
                "batch_size": 1,  # Small batch size for menstrual health data
                "learning_rate_multiplier": 0.1  # Conservative learning rate
            }
        )
        
        job_id = response.id
        print(f"✅ Fine-tuning job created. Job ID: {job_id}")
        print(f"📊 Monitor progress at: https://platform.openai.com/fine-tuning")
        return job_id
    
    def check_job_status(self, job_id: str):
        """Check the status of a fine-tuning job"""
        response = self.client.fine_tuning.jobs.retrieve(job_id)
        
        print(f"📋 Job Status: {response.status}")
        if response.status == "succeeded":
            print(f"🎉 Fine-tuning completed!")
            print(f"🤖 Fine-tuned model ID: {response.fine_tuned_model}")
            return response.fine_tuned_model
        elif response.status == "failed":
            print(f"❌ Fine-tuning failed: {response.error}")
        else:
            print(f"⏳ Job is still {response.status}...")
        
        return None
    
    def test_fine_tuned_model(self, model_id: str, test_messages: List[str]):
        """Test the fine-tuned model with sample questions"""
        print(f"🧪 Testing fine-tuned model: {model_id}")
        
        for i, test_message in enumerate(test_messages, 1):
            print(f"\n--- Test {i} ---")
            print(f"Question: {test_message}")
            
            response = self.client.chat.completions.create(
                model=model_id,
                messages=[
                    {"role": "system", "content": "You are MenstruAI, a specialized assistant for menstrual health."},
                    {"role": "user", "content": test_message}
                ],
                max_tokens=150,
                temperature=0.7
            )
            
            answer = response.choices[0].message.content
            print(f"Answer: {answer}")

def main():
    parser = argparse.ArgumentParser(description='Fine-tune LLM for menstrual health')
    parser.add_argument('--api-key', required=True, help='OpenAI API key')
    parser.add_argument('--training-file', required=True, help='Path to Flutter-exported JSONL file')
    parser.add_argument('--action', choices=['prepare', 'upload', 'train', 'status', 'test'], 
                       required=True, help='Action to perform')
    parser.add_argument('--job-id', help='Fine-tuning job ID (for status check)')
    parser.add_argument('--model-id', help='Fine-tuned model ID (for testing)')
    
    args = parser.parse_args()
    
    fine_tuner = MenstrualHealthFineTuner(args.api_key)
    
    if args.action == 'prepare':
        # Prepare training data
        output_file = args.training_file.replace('.jsonl', '_cleaned.jsonl')
        fine_tuner.prepare_training_data(args.training_file, output_file)
    
    elif args.action == 'upload':
        # Upload training file
        file_id = fine_tuner.upload_training_file(args.training_file)
        print(f"Save this File ID for next step: {file_id}")
    
    elif args.action == 'train':
        # Start fine-tuning (requires file_id from upload step)
        file_id = input("Enter the File ID from upload step: ")
        job_id = fine_tuner.create_fine_tuning_job(file_id)
        print(f"Save this Job ID to check status: {job_id}")
    
    elif args.action == 'status':
        # Check job status
        if not args.job_id:
            args.job_id = input("Enter the Job ID: ")
        model_id = fine_tuner.check_job_status(args.job_id)
        if model_id:
            print(f"Update your Flutter app with this model ID: {model_id}")
    
    elif args.action == 'test':
        # Test fine-tuned model
        if not args.model_id:
            args.model_id = input("Enter the fine-tuned model ID: ")
        
        test_questions = [
            "Why is my period late?",
            "What are normal PMS symptoms?",
            "How can I track ovulation?",
            "I have severe period pain, what should I do?",
            "How does stress affect my cycle?"
        ]
        
        fine_tuner.test_fine_tuned_model(args.model_id, test_questions)

if __name__ == "__main__":
    main()

# Usage Examples:
# python3 fine_tune_menstrual_llm.py --api-key YOUR_KEY --training-file training.jsonl --action prepare
# python3 fine_tune_menstrual_llm.py --api-key YOUR_KEY --training-file training_cleaned.jsonl --action upload
# python3 fine_tune_menstrual_llm.py --api-key YOUR_KEY --training-file training_cleaned.jsonl --action train
# python3 fine_tune_menstrual_llm.py --api-key YOUR_KEY --action status --job-id ftjob-xxx
# python3 fine_tune_menstrual_llm.py --api-key YOUR_KEY --action test --model-id ft:gpt-3.5-turbo-xxx
