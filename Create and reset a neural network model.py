# Create and reset a neural network model
import torch
import torch.nn as nn
import torch.nn.functional as F

class SimpleNet(nn.Module):
    def __init__(self, input_size=784, hidden_size=128, num_classes=10):
        super(SimpleNet, self).__init__()
        self.fc1 = nn.Linear(input_size, hidden_size)
        self.fc2 = nn.Linear(hidden_size, num_classes)
        
    def forward(self, x):
        x = F.relu(self.fc1(x))
        x = self.fc2(x)
        return x

model = SimpleNet()

def train_model(model, epochs=5):
    optimizer = torch.optim.Adam(model.parameters(), lr=0.001)
    criterion = nn.CrossEntropyLoss()

    x = torch.randn(100, 784)  
    y = torch.randint(0, 10, (100,))  
    
    for epoch in range(epochs):
        outputs = model(x)
        loss = criterion(outputs, y)
        
        optimizer.zero_grad()
        loss.backward()
        optimizer.step()
        
        print(f'Epoch [{epoch+1}/{epochs}], Loss: {loss.item():.4f}')

def run_experiment(num_experiments=3):
    torch.manual_seed(42)
    
    for i in range(num_experiments):
        print(f"\nExperiment {i+1}")

        model = SimpleNet()  
        train_model(model)

run_experiment()

'''
# Wrong approach: Using the same model instance for multiple training sessions
model = SimpleNet()
train_model(model)  # First training
train_model(model)  # Second training - model continues training from previous state

# Correct approach: Using a new model instance for each training session
model1 = SimpleNet()
train_model(model1)  # First experiment

model2 = SimpleNet()
train_model(model2)  # Second experiment
'''
