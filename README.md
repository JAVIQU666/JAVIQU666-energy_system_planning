# Joint Planning of Economy and Reliability for Integrated Community Energy Systems

This repository provides the implementation of the paper:

**“Joint Planning of Economy and Reliability for Integrated Community Energy Systems: A Similarity-Based Massive Scenario Optimization Approach”**

## 📌 Description

This project develops a joint planning model for integrated community energy systems (ICES), considering:

- Economic cost  
- System reliability  
- Uncertainty of renewable generation and load  

To handle massive uncertainty scenarios, a similarity-based scenario reduction method is applied to improve computational efficiency while maintaining accuracy.

---

## ⚙️ Main Components

- Massive scenario generation  
- Similarity-based scenario clustering  
- Scenario reduction  
- Joint economic–reliability optimization model

- ## 🚀 Code Running Instructions

The program can be executed directly by running:

```matlab
main.m
```

### 📂 File Description

- `main.m`  
  Main script of the project. Run this file to execute the optimization model.

- `getpara.m`  
  Parameter file for the base scenario sensitivity analysis.

- `getparaDR.m`  
  Parameter file for the demand response (DR) scenario sensitivity analysis.

- `getparaeco.m`  
  Parameter file for the economic parameter sensitivity analysis.

- `Equip_set.m`  
  Equipment parameter settings.

- `sp_mosekcal.m`  
  Implementation of the state similarity-based calculation method.

---

Before running the code, please make sure that all required solvers (e.g., MOSEK) and toolboxes are properly installed and configured in MATLAB.
