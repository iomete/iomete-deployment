resource "kubernetes_config_map" "producer_scripts" {
  metadata {
    name      = "kafka-data-producer-scripts"
    namespace = var.namespace
  }

  data = {
    "producer.py" = <<-EOF
#!/usr/bin/env python3
import json
import time
import random
import os
from datetime import datetime, timedelta
from kafka import KafkaProducer
from kafka.errors import NoBrokersAvailable
import uuid

BOOTSTRAP_SERVERS = os.environ.get('KAFKA_BOOTSTRAP_SERVERS', 'localhost:9092')
TOPIC = os.environ.get('KAFKA_TOPIC', 'events')
DATA_TYPE = os.environ.get('DATA_TYPE', 'e-commerce')
INTERVAL = int(os.environ.get('MESSAGE_INTERVAL_SECONDS', '5'))

# Sample data for realistic generation
PRODUCTS = [
    {"id": "P001", "name": "Laptop Pro 15", "category": "Electronics", "price": 1299.99},
    {"id": "P002", "name": "Wireless Mouse", "category": "Electronics", "price": 49.99},
    {"id": "P003", "name": "USB-C Hub", "category": "Electronics", "price": 79.99},
    {"id": "P004", "name": "Coffee Maker", "category": "Home", "price": 129.99},
    {"id": "P005", "name": "Standing Desk", "category": "Furniture", "price": 499.99},
    {"id": "P006", "name": "Office Chair", "category": "Furniture", "price": 299.99},
    {"id": "P007", "name": "Notebook Set", "category": "Stationery", "price": 24.99},
    {"id": "P008", "name": "Wireless Headphones", "category": "Electronics", "price": 199.99},
    {"id": "P009", "name": "Smart Watch", "category": "Electronics", "price": 349.99},
    {"id": "P010", "name": "Yoga Mat", "category": "Sports", "price": 29.99}
]

USERS = [f"user_{i:03d}" for i in range(1, 101)]
COUNTRIES = ["US", "UK", "DE", "FR", "JP", "CA", "AU", "IT", "ES", "NL"]
CITIES = {
    "US": ["New York", "Los Angeles", "Chicago", "Houston", "Phoenix"],
    "UK": ["London", "Manchester", "Birmingham", "Leeds", "Glasgow"],
    "DE": ["Berlin", "Munich", "Hamburg", "Frankfurt", "Cologne"],
    "FR": ["Paris", "Lyon", "Marseille", "Toulouse", "Nice"],
    "JP": ["Tokyo", "Osaka", "Kyoto", "Yokohama", "Nagoya"],
    "CA": ["Toronto", "Vancouver", "Montreal", "Calgary", "Ottawa"],
    "AU": ["Sydney", "Melbourne", "Brisbane", "Perth", "Adelaide"],
    "IT": ["Rome", "Milan", "Naples", "Turin", "Palermo"],
    "ES": ["Madrid", "Barcelona", "Valencia", "Seville", "Bilbao"],
    "NL": ["Amsterdam", "Rotterdam", "The Hague", "Utrecht", "Eindhoven"]
}

def generate_ecommerce_event():
    """Generate e-commerce transaction event"""
    event_types = ["view", "add_to_cart", "purchase", "remove_from_cart"]
    event_type = random.choice(event_types)
    product = random.choice(PRODUCTS)
    user_id = random.choice(USERS)
    country = random.choice(COUNTRIES)
    city = random.choice(CITIES[country])
    
    event = {
        "event_id": str(uuid.uuid4()),
        "event_type": event_type,
        "timestamp": datetime.utcnow().isoformat() + "Z",
        "user_id": user_id,
        "session_id": f"session_{user_id}_{random.randint(1000, 9999)}",
        "product": {
            "product_id": product["id"],
            "product_name": product["name"],
            "category": product["category"],
            "price": product["price"]
        },
        "quantity": random.randint(1, 3) if event_type in ["add_to_cart", "purchase"] else None,
        "total_amount": round(product["price"] * random.randint(1, 3), 2) if event_type == "purchase" else None,
        "location": {
            "country": country,
            "city": city,
            "ip_address": f"{random.randint(1,255)}.{random.randint(1,255)}.{random.randint(1,255)}.{random.randint(1,255)}"
        },
        "device": {
            "type": random.choice(["desktop", "mobile", "tablet"]),
            "os": random.choice(["Windows", "macOS", "iOS", "Android", "Linux"]),
            "browser": random.choice(["Chrome", "Firefox", "Safari", "Edge", "Opera"])
        }
    }
    
    # Remove None values
    return {k: v for k, v in event.items() if v is not None}

def generate_iot_event():
    """Generate IoT sensor data event"""
    device_types = ["temperature", "humidity", "pressure", "motion", "light"]
    device_type = random.choice(device_types)
    device_id = f"sensor_{device_type}_{random.randint(100, 999)}"
    
    base_event = {
        "device_id": device_id,
        "device_type": device_type,
        "timestamp": datetime.utcnow().isoformat() + "Z",
        "location": {
            "building": f"Building-{random.choice(['A', 'B', 'C'])}",
            "floor": random.randint(1, 10),
            "room": f"Room-{random.randint(100, 199)}"
        },
        "battery_level": random.randint(20, 100),
        "signal_strength": random.randint(-90, -30)
    }
    
    # Add specific sensor data based on type
    if device_type == "temperature":
        base_event["temperature_celsius"] = round(random.uniform(18.0, 28.0), 2)
        base_event["unit"] = "celsius"
    elif device_type == "humidity":
        base_event["humidity_percent"] = round(random.uniform(30.0, 70.0), 2)
        base_event["unit"] = "percent"
    elif device_type == "pressure":
        base_event["pressure_hpa"] = round(random.uniform(980.0, 1040.0), 2)
        base_event["unit"] = "hPa"
    elif device_type == "motion":
        base_event["motion_detected"] = random.choice([True, False])
        base_event["confidence"] = round(random.uniform(0.7, 1.0), 2)
    elif device_type == "light":
        base_event["luminosity_lux"] = random.randint(0, 1000)
        base_event["unit"] = "lux"
    
    return base_event

def generate_clickstream_event():
    """Generate web clickstream event"""
    pages = ["/", "/products", "/about", "/contact", "/cart", "/checkout", "/search", "/blog", "/help"]
    referrers = ["google.com", "facebook.com", "twitter.com", "direct", "email", "linkedin.com"]
    
    user_id = random.choice(USERS)
    session_id = f"web_session_{user_id}_{random.randint(10000, 99999)}"
    
    event = {
        "event_id": str(uuid.uuid4()),
        "timestamp": datetime.utcnow().isoformat() + "Z",
        "user_id": user_id,
        "session_id": session_id,
        "page_url": random.choice(pages),
        "referrer": random.choice(referrers),
        "action": random.choice(["page_view", "click", "scroll", "form_submit"]),
        "time_on_page_seconds": random.randint(5, 300),
        "click_coordinates": {
            "x": random.randint(0, 1920),
            "y": random.randint(0, 1080)
        } if random.random() > 0.5 else None,
        "user_agent": random.choice([
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/91.0.4472.124",
            "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) Safari/14.1.1",
            "Mozilla/5.0 (X11; Linux x86_64) Firefox/89.0"
        ]),
        "viewport": {
            "width": random.choice([1920, 1366, 1280, 768, 414]),
            "height": random.choice([1080, 768, 720, 896, 736])
        }
    }
    
    # Remove None values
    return {k: v for k, v in event.items() if v is not None}

def main():
    print(f"Starting Kafka data producer...")
    print(f"Bootstrap servers: {BOOTSTRAP_SERVERS}")
    print(f"Topic: {TOPIC}")
    print(f"Data type: {DATA_TYPE}")
    print(f"Interval: {INTERVAL} seconds")
    
    # Wait for Kafka to be ready
    producer = None
    retry_count = 0
    max_retries = 12  # 2 minutes with 10 second intervals
    
    while producer is None and retry_count < max_retries:
        try:
            producer = KafkaProducer(
                bootstrap_servers=BOOTSTRAP_SERVERS.split(','),
                value_serializer=lambda v: json.dumps(v).encode('utf-8'),
                acks='all',
                retries=3,
                max_in_flight_requests_per_connection=1
            )
            print("Successfully connected to Kafka")
        except NoBrokersAvailable:
            retry_count += 1
            print(f"Kafka not available yet, retrying... ({retry_count}/{max_retries})")
            time.sleep(10)
    
    if producer is None:
        print("Failed to connect to Kafka after retries")
        exit(1)
    
    message_count = 0
    
    try:
        while True:
            # Generate event based on data type
            if DATA_TYPE == "e-commerce":
                event = generate_ecommerce_event()
            elif DATA_TYPE == "iot":
                event = generate_iot_event()
            elif DATA_TYPE == "clickstream":
                event = generate_clickstream_event()
            else:
                print(f"Unknown data type: {DATA_TYPE}, using e-commerce")
                event = generate_ecommerce_event()
            
            # Send to Kafka
            future = producer.send(TOPIC, value=event)
            record_metadata = future.get(timeout=10)
            
            message_count += 1
            print(f"Message {message_count} sent to {record_metadata.topic} partition {record_metadata.partition} offset {record_metadata.offset}")
            print(f"Event: {json.dumps(event, indent=2)}")
            
            time.sleep(INTERVAL)
            
    except KeyboardInterrupt:
        print("Shutting down producer...")
    except Exception as e:
        print(f"Error: {e}")
    finally:
        if producer:
            producer.close()
        print(f"Producer stopped. Total messages sent: {message_count}")

if __name__ == "__main__":
    main()
EOF
  }
}