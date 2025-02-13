import math
from collections import defaultdict
import numpy as np

class TFIDFCalculator:
    def __init__(self):
        self.documents = []
        self.word_doc_freq = defaultdict(int)
        
    def read_documents(self, filename):
        """Read documents from input file"""
        with open(filename, 'r') as f:
            self.documents = [line.strip().split() for line in f if line.strip()]
        
        # Calculate document frequency for each word
        for doc in self.documents:
            words_seen = set()
            for word in doc:
                if word not in words_seen:
                    self.word_doc_freq[word] += 1
                    words_seen.add(word)
    
    def calculate_tf(self, term, document):
        """Calculate term frequency"""
        return document.count(term) / len(document)
    
    def calculate_idf(self, term):
        """Calculate inverse document frequency"""
        return math.log(len(self.documents) / self.word_doc_freq[term])
    
    def calculate_tfidf(self):
        """Calculate TF-IDF vectors for all documents"""
        tfidf_vectors = []
        
        for doc_idx, doc in enumerate(self.documents):
            doc_vector = {}
            # Get unique words in document
            unique_words = set(doc)
            
            # Calculate TF-IDF for each word
            for word in unique_words:
                tf = self.calculate_tf(word, doc)
                idf = self.calculate_idf(word)
                doc_vector[word] = tf * idf
            
            # Normalize the vector
            magnitude = math.sqrt(sum(value ** 2 for value in doc_vector.values()))
            normalized_vector = {word: value/magnitude 
                              for word, value in doc_vector.items()}
            
            tfidf_vectors.append(normalized_vector)
            
            # Print to console
            print(f"The normalized TF-IDF value for Document {doc_idx}:")
            for word, value in normalized_vector.items():
                print(f"{word}:{value:.17f}", end=' ')
            print("\n")
            
        return tfidf_vectors
    
    def write_output(self, vectors, output_filename):
        """Write normalized TF-IDF vectors to output file"""
        with open(output_filename, 'w') as f:
            for vector in vectors:
                line = ' '.join(f"{word}:{value:.17f}" 
                              for word, value in vector.items())
                f.write(line + '\n')

def main():
    calculator = TFIDFCalculator()
    
    # Read input documents
    input_filename = "review2.txt"
    output_filename = "output.txt"
    
    calculator.read_documents(input_filename)
    tfidf_vectors = calculator.calculate_tfidf()
    calculator.write_output(tfidf_vectors, output_filename)

if __name__ == "__main__":
    main()
