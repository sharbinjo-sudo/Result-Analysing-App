import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.linear_model import Ridge
from sklearn.metrics import mean_squared_error, r2_score
df = pd.read_csv("co_regression_data.csv")
X = df[
    [
        "CO1", "CO2", "CO3", "CO4",
        "L", "T", "P", "C",
        "feedback_score",
        "course_type"
    ]
]

y = df["CO5"]
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42
)
model = Ridge(alpha=1.0)
model.fit(X_train, y_train)
y_pred = model.predict(X_test)
mse = mean_squared_error(y_test, y_pred)
r2 = r2_score(y_test, y_pred)

print("Mean Squared Error:", round(mse, 3))
print("R2 Score:", round(r2, 3))
example_input = [[
    72, 70, 71, 73,
    3, 1, 0, 4,
    -0.1,
    0
]]

predicted_co5 = model.predict(example_input)
print("Predicted CO5:", round(predicted_co5[0], 2))
