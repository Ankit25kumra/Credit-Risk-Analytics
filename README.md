# Credit Risk Analytics Dashboard

A Streamlit web application for credit risk analysis, exploratory data analysis, and customer risk scoring.

## Features

- Dashboard with customer, default, credit score, and income metrics
- Exploratory data analysis with feature distributions and correlation charts
- Model information page with feature groups and model configuration
- Credit risk prediction form with risk score, level, and recommendation
- Performance page with metrics, confusion matrix, and ROC-AUC curve
- Styled sidebar navigation with active menu state and sign-out action
- Single-account login for dashboard access

## Login

Use the following account to access the app:

```text
Username: admin
Password: admin@123
```

## Getting Started

### Prerequisites

- Python 3.8 or higher
- pip

### Installation

Clone the repository and install dependencies:

```bash
git clone https://github.com/Ankit25kumra/Credit-Risk-Analytics.git
cd Credit-Risk-Analytics
pip install -r requirements.txt
```

### Run the App

```bash
streamlit run app.py
```

The app will run locally at:

```text
http://localhost:8501
```

## Project Structure

```text
credit_app/
|-- app.py                    # Main Streamlit application
|-- final_data_set.csv         # Credit risk dataset
|-- requirements.txt           # Python dependencies
|-- train_model.py             # Model training and artifact generation script
|-- RETAIL _BANK_3MODEL.ipynb  # Original notebook/reference work
|-- README.md                  # Project documentation
```

## App Pages

### Dashboard

Shows key indicators such as total customers, default rate, average credit score, average annual income, default distribution, and delinquency profile.

### EDA

Provides dataset shape, missing data summary, feature distributions, descriptive statistics, and correlation analysis against `Default_Flag`.

### Model Info

Documents the Logistic Regression model, target variable, feature categories, and high-level model configuration.

### Predict Risk

Accepts customer details and returns a calculated risk score, risk level, decision recommendation, risk factors, and positive factors.

### Performance

Displays model performance metrics, confusion matrix, ROC-AUC curve, strengths, improvement areas, and recommendations.

## Technologies

- Streamlit
- Pandas
- NumPy
- Scikit-learn
- Matplotlib
- Seaborn

## Model Details

- Model type: Logistic Regression
- Target variable: `Default_Flag`
- Dataset size: 51,336 records with 96 features
- Reported metrics:
  - Accuracy: ~94%
  - Precision: ~92%
  - Recall: ~85%
  - F1 Score: ~88%
  - ROC-AUC: ~0.91

## Notes

- Keep `final_data_set.csv` in the same directory as `app.py`.
- `.streamlit/secrets.toml` and `.venv/` are intentionally ignored by Git.
- Run `train_model.py` only when you need to regenerate model artifacts.
