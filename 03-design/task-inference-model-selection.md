# Inference Model Selection Task

## Design Summary
- Keep provider creation behind `InferenceProviderFactory`.
- Return both the provider instance and resolution metadata:
  - requested model
  - active effective model
  - runtime availability
  - status message
- Let `HomeController` own selection changes and persistence, while widgets remain callback-driven.
