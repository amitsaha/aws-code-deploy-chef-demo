# Paths
cookbook_path  [
    File.join(File.expand_path('../', __FILE__), "./cookbooks"),
    File.join(File.expand_path('../', __FILE__), "./public-cookbooks"),
]

# Logging
log_level      :info   # Log additional info
log_location   STDOUT  # Write logs to the terminal