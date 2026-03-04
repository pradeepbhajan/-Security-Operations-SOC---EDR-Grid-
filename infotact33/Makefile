.PHONY: install test clean setup deploy

install:
	pip install -r requirements.txt

test:
	pytest tests/ -v

setup:
	sudo bash scripts/setup.sh

deploy-agent:
	bash scripts/deploy-agent.sh $(TARGET_IP) $(MANAGER_IP)

clean:
	find . -type d -name __pycache__ -exec rm -rf {} +
	find . -type f -name "*.pyc" -delete
	rm -rf htmlcov/ .coverage .pytest_cache/

docker-up:
	docker-compose up -d

docker-down:
	docker-compose down

logs:
	tail -f /var/ossec/logs/alerts/alerts.log
