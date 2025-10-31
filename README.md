# Terraform Presentation with Django Example

This project demonstrates how to deploy a **Django application** using **Terraform** on AWS. It includes modular Terraform code for networking, compute, and storage.

---

## Project Structure

terraform-presentation-python/
├── app-source/ # Django application source
├── terraform/ # Terraform infrastructure
│ ├── modules/ # Reusable Terraform modules
│ │ ├── network/
│ │ ├── compute/
│ │ └── storage/
│ └── environments/ # Environment-specific configurations
│ └── dev/
└── README.md

yaml
Kód másolása

---

## Prerequisites

- Python 3.9+ (for the Django app)
- Terraform 1.5+
- AWS CLI configured with valid credentials
- Git

---

## Django App Setup (Local)

```bash
cd app-source
python -m venv .venv
# On Windows:
.venv\Scripts\activate
# On Linux/Mac:
source .venv/bin/activate
pip install -r requirements.txt
python manage.py migrate
python manage.py collectstatic --noinput
python manage.py runserver 0.0.0.0:8000
Visit http://localhost:8000 to see the app running locally.
