import ballerina/http;
import ballerina/log;
import ballerina/random;

service /api on new http:Listener(9000) {

    public function init() {
        log:printInfo("Sentiment analysis service started");
    }

    resource function post sentiment(Content content) returns Sentiment {
        do {
            decimal pos = check random:createDecimal().ensureType();
            decimal neg = check random:createDecimal().ensureType();
            if pos + neg > 1d {
                pos = pos / (pos + neg);
                neg = neg / (pos + neg);
            }
            decimal neutral = 1 - (pos + neg);
            Sentiment sentiment = {
                probability: {
                    neg: neg,
                    neutral: neutral,
                    pos: pos
                },
                label: pos > neg ? (pos > neutral ? POS : NEUTRAL) : (neg > neutral ? NEG : NEUTRAL)
            };
            return sentiment;
        } on fail {
            return {
                probability: {
                    neg: 0.30135019761690551,
                    neutral: 0.27119050546800266,
                    pos: 0.69864980238309449
                },
                label: POS
            };
        }
    }
}

type Probability record {
    decimal neg;
    decimal neutral;
    decimal pos;
};

enum SentimentLabel {
    NEG = "neg",
    NEUTRAL = "neutral",
    POS = "pos"
};

type Sentiment record {
    Probability probability;
    SentimentLabel label;
};

type Content record {
    string text;
};
