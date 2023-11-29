from influxdb_client import InfluxDBClient
from influxdb_client.client.write_api import ASYNCHRONOUS

class Singleton(type):
    _instances = {}
    def __call__(cls, *args, **kwargs):
        if cls not in cls._instances:
            cls._instances[cls] = super(Singleton, cls).__call__(*args, **kwargs)
        return cls._instances[cls]

class InfluxDBSender(metaclass=Singleton):
    def __init__(self, host=None, token=None, organization=None, bucket=None, metric_prefix=None):
        if host and token and organization and bucket and metric_prefix:
            self.host = host
            self.token = token
            self.organization = organization
            self.bucket = bucket
            self.metric_prefix = metric_prefix
            self.client = None
            self.write_api = None

    def initialize_sender(self):
        if self.client:
            self.client.close()
            self.write_api = None
        self.client = InfluxDBClient(url=self.host, token=self.token, org=self.organization, bucket=self.bucket)
        self.write_api = self.client.write_api(write_options=ASYNCHRONOUS)

    def send_data(self, metric_name, value):
        full_metric_name = self.metric_prefix + "." + metric_name
        data = {
            "measurement": full_metric_name,
            "fields": {
                "value": value
            }
        }
        self.write_api.write(bucket=self.bucket, record=data)

    def close_sender(self):
        if self.client:
            self.client.close()
            self.client = None
