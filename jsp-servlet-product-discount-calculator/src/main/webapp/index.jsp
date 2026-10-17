<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Product Discount Calculator</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            display: flex;
            justify-content: center;
            margin-top: 80px;
            background-color: #f8fafc;
        }
        .calculator-container {
            background: white;
            padding: 35px;
            border-radius: 8px;
            box-shadow: 0 4px 10px rgba(0,0,0,0.1);
            width: 400px;
        }
        h2 {
            color: #1b2a7a;
            text-align: center;
            margin-bottom: 25px;
        }
        .form-group {
            margin-bottom: 15px;
        }
        label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
            color: #334155;
        }
        input[type="text"],
        input[type="number"] {
            width: 100%;
            padding: 10px;
            border: 1px solid #cbd5e1;
            border-radius: 4px;
            box-sizing: border-box;
            font-size: 14px;
        }
        button {
            width: 100%;
            background-color: #1b2a7a;
            color: white;
            padding: 12px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 16px;
            font-weight: bold;
            margin-top: 10px;
        }
        button:hover {
            background-color: #121c54;
        }
    </style>
</head>
<body>
    <div class="calculator-container">
        <h2>Product Discount Calculator</h2>
        <form action="display-discount" method="POST">
            <div class="form-group">
                <label>Product Description:</label>
                <input type="text" name="description" placeholder="Nhập mô tả sản phẩm" required />
            </div>
            <div class="form-group">
                <label>List Price ($):</label>
                <input type="number" name="price" placeholder="Nhập giá niêm yết" required min="0" step="any" />
            </div>
            <div class="form-group">
                <label>Discount Percent (%):</label>
                <input type="number" name="discount" placeholder="Nhập tỷ lệ chiết khấu (%)" required min="0" max="100" step="any" />
            </div>
            <button type="submit">Calculate Discount</button>
        </form>
    </div>
</body>
</html>
