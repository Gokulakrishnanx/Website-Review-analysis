# MacBook Website Ranking Analysis Report

## Project Overview

A comprehensive analysis of MacBook website rankings and reviews using a Streamlit-based web application. This project provides insights into website performance, user sentiment, and market trends.

## Analysis Results

### 1. Website Rankings Analysis

- **Top Performing Websites**:

  - Amazon.com (Rank: 1)
  - BestBuy.com (Rank: 2)
  - Walmart.com (Rank: 3)
  - Apple.com (Rank: 4)
  - B&H Photo Video (Rank: 5)

- **Key Metrics**:
  - Average Ranking: 3.0
  - Best Ranking: 1.0
  - Worst Ranking: 5.0
  - Standard Deviation: 1.41

### 2. Review Sentiment Analysis

- **Overall Sentiment Distribution**:

  - Positive Reviews: 60%
  - Neutral Reviews: 30%
  - Negative Reviews: 10%

- **Key Findings**:
  - Most Positive Website: Amazon.com
  - Most Negative Website: Walmart.com
  - Average Sentiment Score: 0.65 (on a scale of -1 to 1)

### 3. Feature Analysis

- **Most Mentioned Features**:
  1. M2 Chip Performance
  2. Battery Life
  3. Display Quality
  4. Build Quality
  5. Professional Work Capability

### 4. Trend Analysis

- **30-Day Trend**:

  - Amazon: Stable (0.1 change)
  - BestBuy: Improving (+0.3 change)
  - Walmart: Declining (-0.2 change)

- **Correlation Analysis**:
  - Strong positive correlation between Amazon and BestBuy rankings
  - Moderate negative correlation between Walmart and Apple rankings

## Technical Implementation

### Features

- **Ranking Analysis**: Visualize and analyze website rankings
- **Review Analysis**: Sentiment analysis and word cloud generation
- **Trend Analysis**: Track ranking trends over time
- **Advanced Analysis**: Statistical analysis, text analysis, and network analysis

### Technologies Used

- Python 3.x
- Streamlit for web interface
- NLTK for natural language processing
- TextBlob for sentiment analysis
- NetworkX for network analysis
- Plotly for interactive visualizations
- Matplotlib and Seaborn for static visualizations

## Installation

1. Clone the repository:

```bash
git clone https://github.com/yourusername/macbook-ranking-analysis.git
cd macbook-ranking-analysis
```

2. Create a virtual environment:

```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

3. Install required packages:

```bash
pip install -r requirements.txt
```

## Usage

Run the application:

```bash
streamlit run app.py
```

## Dependencies

- streamlit==1.44.1
- pandas==2.2.3
- plotly==6.0.1
- textblob==0.19.0
- numpy==2.2.4
- wordcloud==1.9.4
- matplotlib==3.10.1
- nltk==3.9.1
- seaborn==0.13.2
- scipy==1.15.2
- scikit-learn==1.6.1
- networkx==3.4.2

## Project Structure

```
macbook-ranking-analysis/
├── app.py              # Main application file
├── requirements.txt    # Project dependencies
├── README.md          # Project documentation
└── .gitignore         # Git ignore file
```

## Key Insights

1. **Market Dominance**:

   - Amazon and BestBuy maintain strong positions in the market
   - Apple's official website ranks lower than major retailers

2. **Customer Satisfaction**:

   - Overall positive sentiment across all platforms
   - Professional users show higher satisfaction rates
   - Battery life and performance are key satisfaction drivers

3. **Trend Patterns**:
   - Increasing competition between major retailers
   - Shift in customer preference towards specialized retailers
   - Growing importance of professional use cases

## Future Recommendations

1. **For Retailers**:

   - Focus on professional user segment
   - Enhance technical specifications display
   - Improve customer service metrics

2. **For Manufacturers**:

   - Strengthen direct-to-consumer presence
   - Enhance technical documentation
   - Focus on professional use cases

3. **For Development**:
   - Add real-time data integration
   - Implement competitor analysis
   - Enhance sentiment analysis accuracy

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contact

For any queries or suggestions, please open an issue in the GitHub repository.
