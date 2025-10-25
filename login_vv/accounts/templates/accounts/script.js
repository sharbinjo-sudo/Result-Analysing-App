document.getElementById("registerForm").addEventListener("submit", function(e) {
  e.preventDefault(); // stop page reload

  const fullName = document.getElementById("fullname").value.trim();
  const email = document.getElementById("email").value.trim();
  const password = document.getElementById("password").value.trim();

  if (fullName && email && password) {
    alert("Registration successful!\nWelcome, " + fullName);
    // In real app, you would send data to a backend server here
    document.getElementById("registerForm").reset();
  } else {
    alert("Please fill all fields.");
  }
});