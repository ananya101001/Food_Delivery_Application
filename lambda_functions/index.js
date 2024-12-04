const mysql = require('mysql2/promise');

let connection;

exports.handler = async (event) => {
    console.log("Received event:", JSON.stringify(event, null, 2));

    // Extract data from the POST request body
    const body = event.body ? JSON.parse(event.body) : null;

    if (!body || !body.customer_id || !body.restaurant_id) {
        return {
            statusCode: 400,
            headers: {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Credentials': true,
            },
            body: JSON.stringify({ error: "Invalid or missing JSON body. Ensure customer_id and restaurant_id are provided." }),
        };
    }

    const { customer_id, restaurant_id } = body;

    // Database connection parameters
    if (!connection) {
        console.log("Opening DB connection...");
        connection = await mysql.createConnection({
            host: 'food-delivery-db.cl4yg086473r.us-west-1.rds.amazonaws.com',
            user: 'ananya',
            password: 'UberSecretPassword',
            database: 'fooddeliverydb',
        });
    }

    try {
        // Insert the order
        const [orderResult] = await connection.execute(
            'INSERT INTO orders (customer_id, restaurant_id, status) VALUES (?, ?, ?)',
            [customer_id, restaurant_id, 'pending']
        );

        const orderId = orderResult.insertId;

        return {
            statusCode: 201,
            headers: {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Credentials': true,
            },
            body: JSON.stringify({ message: 'Order created successfully', order_id: orderId }),
        };
    } catch (error) {
        console.error("Error creating order:", error);

        return {
            statusCode: 500,
            headers: {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Credentials': true,
            },
            body: JSON.stringify({ error: "Failed to create order: " + error.message }),
        };
    } finally {
        if (connection) {
            await connection.end();
        }
    }
};