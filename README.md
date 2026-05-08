# Credit Risk Analytics Dashboard

A comprehensive Streamlit web application for credit risk analysis and prediction using machine learning.

## Features

- **Dashboard** - Overview of key metrics and statistics
- **EDA** - Exploratory data analysis with interactive visualizations
- **Model Info** - Details about the machine learning model and features
- **Risk Prediction** - Interactive tool to predict credit risk for new customers
- **Performance** - Model performance metrics and evaluation charts

## Getting Started

### Prerequisites
- Python 3.8 or higher
- pip (Python package manager)

### Installation

1. Navigate to the project directory:
```bash
cd credit_app
```

2. Install required packages:
```bash
pip install -r requirements.txt
```

### Running the App

Start the Streamlit application:
```bash
streamlit run app.py
```

The app will open in your default web browser at `http://localhost:8501`

## Project Structure

```
credit_app/
├── app.py                  # Main Streamlit application
├── requirements.txt        # Python dependencies
├── final_data_set.csv      # Credit risk dataset
├── RETAIL_BANK_3MODEL.ipynb  # Original Jupyter notebook
└── README.md              # This file
```

## Dashboard Pages

### 1. Dashboard
Overview of key credit risk metrics:
- Total customers
- Default rate
- Average credit score
- Average income
- Distribution charts

### 2. EDA (Exploratory Data Analysis)
Interactive analysis of the dataset:
- Dataset shape and missing values
- Feature distributions
- Correlation analysis with default flag
- Top correlated features

### 3. Model Info
Information about the machine learning model:
- Model type and objective
- Feature categories and descriptions
- Hyperparameters
- Feature importance

### 4. Risk Prediction
Interactive tool to predict credit risk:
- Input customer information
- Automatic risk score calculation
- Risk level classification
- Risk factors analysis

### 5. Performance
Model performance evaluation:
- Accuracy, Precision, Recall metrics
- F1 Score and ROC-AUC
- Confusion matrix
- ROC curve visualization

## Technologies Used

- **Streamlit** - Web application framework
- **Pandas** - Data manipulation
- **NumPy** - Numerical computing
- **Scikit-learn** - Machine learning
- **Matplotlib & Seaborn** - Data visualization

## Model Details

**Model Type:** Logistic Regression

**Performance Metrics:**
- Accuracy: ~94%
- Precision: ~92%
- Recall: ~85%
- F1 Score: ~88%
- ROC-AUC: ~0.91

**Target Variable:** Default_Flag (Binary Classification)

**Dataset:** 51,336 records with 96 features

## Use Cases

- Credit risk assessment for loan applications
- Customer risk profiling
- Portfolio analysis
- Default prediction
- Risk-based decision making

## Future Enhancements

- Integrate trained model for actual predictions
- Add model retraining functionality
- Implement multi-model comparison
- Add data export features
- Deploy to Streamlit Cloud

## Notes

- Make sure `final_data_set.csv` is in the same directory as `app.py`
- The app requires internet connection for initial load
- For large datasets, consider data filtering or sampling

## Support

For issues or questions, refer to the Streamlit documentation at https://docs.streamlit.io/

## License

This project is created for credit risk analysis purposes.
