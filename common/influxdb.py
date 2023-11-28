from influxdb import InfluxDBClient

class InfluxDBSender:
    def __init__(self, host, token, organization, bucket, metric_prefix):
        self.host = host
        self.token = token
        self.organization = organization
        self.bucket = bucket
        self.metric_prefix = metric_prefix
        self.client = None

    def initialize_sender(self):
        if self.client:
            self.client.close()
        self.client = InfluxDBClient(url=self.host, token=self.token, org=self.organization, bucket=self.bucket)

    def send_data(self, metric_name, value):
        full_metric_name = self.metric_prefix + "." + metric_name
        data = {
            "measurement": full_metric_name,
            "fields": {
                "value": value
            }
        }
        self.client.write_points([data])

    def close_sender(self):
        if self.client:
            self.client.close()
            self.client = None
