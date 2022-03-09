import os, json, argparse, pathlib

from google.cloud import bigquery

class Assignment:
    def __init__(self, bq_client, project_name, dataset_name, sql_folder_path, results_folder_path):
        self.bq_client = bq_client
        self.project_name = project_name
        self.dataset_name = dataset_name
        self.sql_folder_path = pathlib.Path(sql_folder_path)
        self.results_folder_path = pathlib.Path(results_folder_path)
        # Creating results folder if it doesn't exists
        self.results_folder_path.mkdir(parents=True, exist_ok=True)
        self.dataset_id_full = f'{self.project_name}.{self.dataset_name}'
        # Create the new BigQuery dataset if it is not available
        self.create_dataset()

    def run_query(self, query, table_name):
        config = bigquery.QueryJobConfig()
        # Set the query job destination table instead of using a temp table
        config.destination = f'{self.dataset_id_full}.{table_name}'
        config.write_disposition = bigquery.WriteDisposition.WRITE_TRUNCATE
        query_job = self.bq_client.query(query, job_config=config)
        # Saves query's result to Pandas dataframe
        df = query_job.to_dataframe()
        # Using Pandas to save to CSV
        csv_file_path = self.results_folder_path.joinpath(f'{table_name}.csv')
        df.to_csv(csv_file_path, index=False)
        
    def run_question(self, qn_num=1):
        if type(qn_num) != int or qn_num < 1 or qn_num > 4 :
            raise NotImplementedError(f'There are only qn 1 to qn 4, received invalid value for qn_num:{qn_num}')
        
        # Reads question's query in sql_folder
        sql_file_path = self.sql_folder_path.joinpath(f'Qn{qn_num}.sql')

        if not sql_file_path.exists():
            raise ValueError(f'sql_folder arg is invalid:{self.sql_folder_path}')

        with open(sql_file_path) as infile:
            query = infile.read()

        self.run_query(query, f'Qn{qn_num}')

    def create_dataset(self):
        # Create the new BigQuery dataset if it is not available
        self.bq_client.create_dataset(self.dataset_name, exists_ok=True)

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("--project", help="GCP project used, will get from gcloud if not provided", required=False)
    parser.add_argument("--sql_folder", help="Code will load file named Q1..4 with sql extension", required=False, default='queries')
    parser.add_argument("--result_folder", help="Code will load file named Q1..4 with sql extension", required=False, default='results')
    parser.add_argument("--dataset_name", help="Code will load file named Q1..4 with sql extension", required=False, default='delivery_hero')
    args = parser.parse_args()
    if args.project is None:
        if 'GOOGLE_APPLICATION_CREDENTIALS' in os.environ:
            with open(os.environ['GOOGLE_APPLICATION_CREDENTIALS']) as infile:
                credentials = json.load(infile)
            project_id = credentials.get('project_id')
            if project_id is None:
                project_id = credentials.get('quota_project_id')
            if project_id is None:
                raise Exception('Failed to determine project_id')
        else:
            raise Exception('Failed to determine project_id')
    else:
        project_id = args.project
        
    # Construct a BigQuery client object.
    client = bigquery.Client()
    # Construct a Assignment object.
    assignment = Assignment(client, project_id, args.dataset_name, args.sql_folder, args.result_folder)
    # Run query for assignment questions
    assignment.run_question(1)
    assignment.run_question(2)
    assignment.run_question(3)
    assignment.run_question(4)
