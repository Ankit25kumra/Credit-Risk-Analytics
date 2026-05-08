"""
Credit Risk Prediction Model Training & Evaluation
This script trains the Logistic Regression model and saves artifacts for deployment
"""

import pandas as pd
import numpy as np
import pickle
import warnings
warnings.filterwarnings('ignore')

from sklearn.model_selection import train_test_split, cross_val_score
from sklearn.preprocessing import LabelEncoder, StandardScaler
from sklearn.feature_selection import SelectKBest, chi2
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import (
    accuracy_score, precision_score, recall_score, f1_score,
    roc_auc_score, confusion_matrix, classification_report, roc_curve
)
import json

print("=" * 80)
print("CREDIT RISK PREDICTION MODEL TRAINING")
print("=" * 80)

# ======================== STEP 1: LOAD DATA ========================
print("\n[1/8] Loading data...")
df = pd.read_csv('final_data_set.csv')
print(f"✓ Dataset loaded: {df.shape[0]:,} rows, {df.shape[1]} columns")

# ======================== STEP 2: DATA PREPROCESSING ========================
print("\n[2/8] Preprocessing data...")

# Separate numeric and categorical columns
numeric_cols = df.select_dtypes(include=np.number).columns
categorical_cols = df.select_dtypes(include='object').columns

# Handle missing values
for col in numeric_cols:
    df[col] = df[col].fillna(df[col].median())

for col in categorical_cols:
    df[col] = df[col].fillna(df[col].mode()[0])

# Remove duplicates
df = df.drop_duplicates()
print(f"✓ Data preprocessed: {df.shape[0]:,} rows after deduplication")

# ======================== STEP 3: ENCODE CATEGORICAL FEATURES ========================
print("\n[3/8] Encoding categorical features...")
label_encoders = {}

for col in categorical_cols:
    le = LabelEncoder()
    df[col] = le.fit_transform(df[col].astype(str))
    label_encoders[col] = le

print(f"✓ Encoded {len(categorical_cols)} categorical columns")

# ======================== STEP 4: PREPARE FEATURES & TARGET ========================
print("\n[4/8] Preparing features and target...")
X = df.drop('Default_Flag', axis=1)
y = df['Default_Flag']

# Store feature names
feature_names = X.columns.tolist()
print(f"✓ Features: {len(feature_names)}, Target distribution: {y.value_counts().to_dict()}")

# Save default values for all features to support deployment input defaults
feature_defaults = {}
for col in feature_names:
    if col in categorical_cols:
        feature_defaults[col] = df[col].mode()[0]
    else:
        feature_defaults[col] = df[col].median()

# ======================== STEP 5: FEATURE SCALING ========================
print("\n[5/8] Scaling features...")
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)
print(f"✓ Features scaled using StandardScaler")

# ======================== STEP 6: FEATURE SELECTION ========================
print("\n[6/8] Selecting top 20 features...")
selector = SelectKBest(score_func=chi2, k=20)
X_selected = selector.fit_transform(abs(X_scaled), y)

selected_features = feature_names[selector.get_support()]
selected_features = selected_features.tolist()

print(f"\n✓ Selected {len(selected_features)} features:")
for i, feature in enumerate(selected_features, 1):
    print(f"   {i:2d}. {feature}")

# ======================== STEP 7: TRAIN-TEST SPLIT ========================
print("\n[7/8] Splitting data...")
X_train, X_test, y_train, y_test = train_test_split(
    X_selected, y,
    test_size=0.2,
    random_state=42,
    stratify=y
)
print(f"✓ Training: {X_train.shape[0]:,}, Testing: {X_test.shape[0]:,}")

# ======================== STEP 8: MODEL TRAINING ========================
print("\n[8/8] Training Logistic Regression model...")
model = LogisticRegression(
    max_iter=1000,
    class_weight='balanced',
    random_state=42,
    solver='lbfgs'
)
model.fit(X_train, y_train)
print(f"✓ Model trained successfully")

# ======================== MODEL EVALUATION ========================
print("\n" + "=" * 80)
print("MODEL EVALUATION RESULTS")
print("=" * 80)

# Predictions
y_train_pred = model.predict(X_train)
y_test_pred = model.predict(X_test)
y_train_proba = model.predict_proba(X_train)[:, 1]
y_test_proba = model.predict_proba(X_test)[:, 1]

# Training Metrics
train_accuracy = accuracy_score(y_train, y_train_pred)
train_precision = precision_score(y_train, y_train_pred)
train_recall = recall_score(y_train, y_train_pred)
train_f1 = f1_score(y_train, y_train_pred)
train_auc = roc_auc_score(y_train, y_train_proba)

# Testing Metrics
test_accuracy = accuracy_score(y_test, y_test_pred)
test_precision = precision_score(y_test, y_test_pred)
test_recall = recall_score(y_test, y_test_pred)
test_f1 = f1_score(y_test, y_test_pred)
test_auc = roc_auc_score(y_test, y_test_proba)

print("\n📊 TRAINING SET METRICS:")
print(f"  Accuracy:  {train_accuracy:.4f}")
print(f"  Precision: {train_precision:.4f}")
print(f"  Recall:    {train_recall:.4f}")
print(f"  F1 Score:  {train_f1:.4f}")
print(f"  ROC-AUC:   {train_auc:.4f}")

print("\n📊 TESTING SET METRICS:")
print(f"  Accuracy:  {test_accuracy:.4f}")
print(f"  Precision: {test_precision:.4f}")
print(f"  Recall:    {test_recall:.4f}")
print(f"  F1 Score:  {test_f1:.4f}")
print(f"  ROC-AUC:   {test_auc:.4f}")

# Confusion Matrix
cm = confusion_matrix(y_test, y_test_pred)
print(f"\n📋 CONFUSION MATRIX (Test Set):")
print(f"  True Negatives:  {cm[0][0]:6d}")
print(f"  False Positives: {cm[0][1]:6d}")
print(f"  False Negatives: {cm[1][0]:6d}")
print(f"  True Positives:  {cm[1][1]:6d}")

# Classification Report
print(f"\n📄 CLASSIFICATION REPORT (Test Set):")
print(classification_report(y_test, y_test_pred, target_names=['No Default', 'Default']))

# ======================== SAVE MODEL ARTIFACTS ========================
print("\n" + "=" * 80)
print("SAVING MODEL ARTIFACTS")
print("=" * 80)

# Save model
with open('credit_risk_model.pkl', 'wb') as f:
    pickle.dump(model, f)
print("✓ Model saved: credit_risk_model.pkl")

# Save scaler
with open('scaler.pkl', 'wb') as f:
    pickle.dump(scaler, f)
print("✓ Scaler saved: scaler.pkl")

# Save selector
with open('feature_selector.pkl', 'wb') as f:
    pickle.dump(selector, f)
print("✓ Feature selector saved: feature_selector.pkl")

# Save label encoders
with open('label_encoders.pkl', 'wb') as f:
    pickle.dump(label_encoders, f)
print("✓ Label encoders saved: label_encoders.pkl")

# Save feature names and selected features
model_config = {
    'all_features': feature_names,
    'selected_features': selected_features,
    'categorical_columns': categorical_cols.tolist(),
    'numeric_columns': numeric_cols.tolist(),
    'test_accuracy': float(test_accuracy),
    'test_precision': float(test_precision),
    'test_recall': float(test_recall),
    'test_f1': float(test_f1),
    'test_auc': float(test_auc),
    'train_accuracy': float(train_accuracy),
    'confusion_matrix': cm.tolist(),
    'feature_defaults': feature_defaults,
}

with open('model_config.json', 'w') as f:
    json.dump(model_config, f, indent=2)
print("✓ Model config saved: model_config.json")

# ======================== SUMMARY ========================
print("\n" + "=" * 80)
print("✅ MODEL TRAINING COMPLETED SUCCESSFULLY")
print("=" * 80)
print(f"\nArtifacts saved:")
print(f"  • credit_risk_model.pkl")
print(f"  • scaler.pkl")
print(f"  • feature_selector.pkl")
print(f"  • label_encoders.pkl")
print(f"  • model_config.json")
print(f"\nBest Test Performance: {test_accuracy:.2%} Accuracy, {test_auc:.4f} AUC-ROC")
print("\nReady for deployment! 🚀")
