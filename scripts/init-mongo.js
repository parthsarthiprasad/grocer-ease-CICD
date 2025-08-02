// MongoDB initialization script for GrocerEase application

// Switch to the grocer_ease_db database
db = db.getSiblingDB('grocer_ease_db');

// Create collections with proper indexes
db.createCollection('chat_history');
db.createCollection('shopping_list');
db.createCollection('user_preferences');

// Create indexes for better performance
db.chat_history.createIndex({ "user_id": 1, "timestamp": -1 });
db.chat_history.createIndex({ "timestamp": -1 });

db.shopping_list.createIndex({ "user_id": 1 });
db.shopping_list.createIndex({ "updated_at": -1 });

db.user_preferences.createIndex({ "user_id": 1 });
db.user_preferences.createIndex({ "last_updated": -1 });

// Create a user for testing
db.user_preferences.insertOne({
    user_id: "test_user",
    preferences: {
        vegetarian: "not_set"
    },
    last_updated: new Date()
});

// Create a sample shopping list
db.shopping_list.insertOne({
    user_id: "test_user",
    items: [
        { name: "milk", quantity: 1, unit: "gallon" },
        { name: "bread", quantity: 2, unit: "loaf" }
    ],
    updated_at: new Date()
});

// Create a sample chat history
db.chat_history.insertOne({
    user_id: "test_user",
    user_message: "Hello, I need help with my shopping list",
    bot_response: "Hello! I'm here to help you with your shopping list. What would you like to add?",
    timestamp: new Date()
});

print("MongoDB initialization completed successfully!");
print("Database: grocer_ease_db");
print("Collections created: chat_history, shopping_list, user_preferences");
print("Sample data inserted for test_user"); 