// DOM Elements
const analyzeBtn = document.getElementById('analyzeBtn');
const tabBtns = document.querySelectorAll('.tab-btn');
const tabPanes = document.querySelectorAll('.tab-pane');
const websitesInput = document.getElementById('websites');
const rankingsInput = document.getElementById('rankings');
const reviewsInput = document.getElementById('reviews');

// Sample data for testing
const sampleData = {
    websites: ['amazon.com', 'bestbuy.com', 'walmart.com', 'apple.com', 'bhphotovideo.com'],
    rankings: [1, 2, 3, 4, 5],
    reviews: [
        "Great product! The M2 chip is amazing. Battery life is excellent. Perfect for professional work.",
        "Best MacBook I've ever used. Display is stunning. Performance is incredible.",
        "Good value for money. Performance is top-notch. Battery life could be better.",
        "Perfect for professional work. Build quality is exceptional. M2 chip is powerful.",
        "Excellent customer service. Product meets expectations. Display quality is great."
    ]
};

// Initialize sample data
function initializeSampleData() {
    websitesInput.value = sampleData.websites.join('\n');
    rankingsInput.value = sampleData.rankings.join('\n');
    reviewsInput.value = sampleData.reviews.join('\n');
}

// Tab switching functionality
function switchTab(tabId) {
    tabBtns.forEach(btn => {
        btn.classList.remove('active');
        if (btn.dataset.tab === tabId) {
            btn.classList.add('active');
        }
    });

    tabPanes.forEach(pane => {
        pane.classList.remove('active');
        if (pane.id === tabId) {
            pane.classList.add('active');
        }
    });
}

// Data processing functions
function processData() {
    const websites = websitesInput.value.split('\n').filter(w => w.trim());
    const rankings = rankingsInput.value.split('\n').map(r => parseInt(r.trim()));
    const reviews = reviewsInput.value.split('\n').filter(r => r.trim());

    return {
        websites,
        rankings,
        reviews
    };
}

// Sentiment analysis
function analyzeSentiment(text) {
    // Simple sentiment analysis (can be replaced with more sophisticated methods)
    const positiveWords = ['great', 'best', 'excellent', 'perfect', 'amazing', 'incredible', 'powerful'];
    const negativeWords = ['could be better', 'not good', 'poor', 'bad', 'terrible'];
    
    const words = text.toLowerCase().split(' ');
    let sentiment = 0;
    
    words.forEach(word => {
        if (positiveWords.includes(word)) sentiment++;
        if (negativeWords.includes(word)) sentiment--;
    });
    
    return sentiment;
}

// Create ranking chart
function createRankingChart(data) {
    const trace = {
        x: data.websites,
        y: data.rankings,
        type: 'bar',
        marker: {
            color: '#007aff'
        }
    };

    const layout = {
        title: 'Website Rankings',
        xaxis: { title: 'Website' },
        yaxis: { title: 'Ranking (Lower is Better)' },
        showlegend: false
    };

    Plotly.newPlot('rankingChart', [trace], layout);
}

// Create sentiment chart
function createSentimentChart(data) {
    const sentiments = data.reviews.map(review => analyzeSentiment(review));
    
    const trace = {
        x: data.websites,
        y: sentiments,
        type: 'bar',
        marker: {
            color: sentiments.map(s => s >= 0 ? '#34c759' : '#ff3b30')
        }
    };

    const layout = {
        title: 'Review Sentiment Analysis',
        xaxis: { title: 'Website' },
        yaxis: { title: 'Sentiment Score' },
        showlegend: false
    };

    Plotly.newPlot('sentimentChart', [trace], layout);
}

// Create trend chart
function createTrendChart(data) {
    const dates = Array.from({length: 30}, (_, i) => {
        const date = new Date();
        date.setDate(date.getDate() - i);
        return date.toISOString().split('T')[0];
    }).reverse();

    const traces = data.websites.map((website, index) => ({
        name: website,
        x: dates,
        y: dates.map(() => data.rankings[index] + Math.random() * 0.5 - 0.25),
        type: 'scatter',
        mode: 'lines+markers'
    }));

    const layout = {
        title: 'Ranking Trends Over Time',
        xaxis: { title: 'Date' },
        yaxis: { title: 'Ranking' },
        showlegend: true
    };

    Plotly.newPlot('trendChart', traces, layout);
}

// Update metrics
function updateMetrics(data) {
    // Ranking metrics
    document.getElementById('avgRanking').textContent = 
        (data.rankings.reduce((a, b) => a + b, 0) / data.rankings.length).toFixed(1);
    document.getElementById('bestRanking').textContent = Math.min(...data.rankings);
    document.getElementById('worstRanking').textContent = Math.max(...data.rankings);

    // Sentiment metrics
    const sentiments = data.reviews.map(review => analyzeSentiment(review));
    const avgSentiment = sentiments.reduce((a, b) => a + b, 0) / sentiments.length;
    document.getElementById('avgSentiment').textContent = avgSentiment.toFixed(1);

    const maxSentimentIndex = sentiments.indexOf(Math.max(...sentiments));
    const minSentimentIndex = sentiments.indexOf(Math.min(...sentiments));
    document.getElementById('mostPositive').textContent = data.websites[maxSentimentIndex];
    document.getElementById('mostNegative').textContent = data.websites[minSentimentIndex];

    // Trend metrics
    document.getElementById('amazonTrend').textContent = 'Stable';
    document.getElementById('bestbuyTrend').textContent = 'Improving';
    document.getElementById('walmartTrend').textContent = 'Declining';
}

// Event Listeners
analyzeBtn.addEventListener('click', () => {
    const data = processData();
    createRankingChart(data);
    createSentimentChart(data);
    createTrendChart(data);
    updateMetrics(data);
});

tabBtns.forEach(btn => {
    btn.addEventListener('click', () => {
        switchTab(btn.dataset.tab);
    });
});

// Initialize the application
initializeSampleData(); 