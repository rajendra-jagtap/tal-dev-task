FROM python:2.7-alpine

# Create app directory
WORKDIR /opt/app

#RUN cd /root/task-2 && git clone https://github.com/macloo/basic-flask-app

COPY . .

RUN python -m pip install --upgrade pip
RUN pip install -r requirements.txt

ENV FLASK_APP="routes.py"

EXPOSE 5000
CMD [ "python", "-m" , "flask", "run", "--host=0.0.0.0"]
