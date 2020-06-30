import asyncio
import datetime
import json
from typing import Tuple, Dict

import arrow
import requests
from python_graphql_client import GraphqlClient

CANVAS_ACCESS_KEY = "fjdhfkjdshfk"
GRAPHQL_API_URL = "https://bibsys.instructure.com/api/graphql"
COURSE_ID = "289"


def compare_date(node):
    """
    If lastActivityAt time is in last 24 , then return true
    :param node: Enrollment object
    :return: boolean
    """
    if "node" in node:
        activity_item = node["node"]['lastActivityAt']
    else:
        activity_item = node['last_activity_at']
    if not activity_item:
        return False
    yesterday = arrow.utcnow().shift(days=-1)
    last_activity_at = arrow.get(activity_item)
    return last_activity_at >= yesterday


def filter_enrollment_activity_by_date(data):
    """
    Filter enrollment activity
    :param data: Dict
    :return:
    """

    active_users_yesterday = list(filter(compare_date, data))
    return len(active_users_yesterday)


class EnrollmentActivity(object):
    def __init__(self, access_token: str, graphql_api_url: str, course_id: str) -> None:
        self.access_token = access_token
        self.course_id = course_id
        self.headers = {'Authorization': 'Bearer ' + self.access_token,
                        "Content-Type": "application/json"}
        self.variables = {"courseId": self.course_id, "first": 500}
        self.query = """
                    query courseEnrollment($courseId: ID!, $first: Int) {
                      course(id: $courseId) {
                        name
                        enrollmentsConnection(first: $first){
                          edges{
                            node{
                              lastActivityAt
                              type
                            }
                          cursor
                          }
                          pageInfo {
                            endCursor
                            hasNextPage
                          }
                        }
                      }
                    }
                """
        self.client = GraphqlClient(endpoint=graphql_api_url, headers=self.headers)
        self.web_session = requests.Session()
        self.web_session.headers.update({
            "Authorization": f"Bearer {CANVAS_ACCESS_KEY}"
        })

    def fetch_enrollment_activity_graphql(self):
        """
        Fetch enrollment activity for a given course and ingest into kpas-api
        :return:
        """
        active_users_count = 0
        enrollment_activity = {}
        try:
            result = self.client.execute(query=self.query, variables=self.variables)
        except Exception as err:
            print("EnrollmentActivity error : {0}".format(err))
            raise
        data = result["data"]["course"]["enrollmentsConnection"]["edges"]
        active_users_count += filter_enrollment_activity_by_date(data)
        second_query = """
            query courseEnrollment($courseId: ID!, $first: Int, $after: String) {
              course(id: $courseId) {
                name
                enrollmentsConnection(first: $first, after: $after){
                  edges{
                    node{
                      lastActivityAt
                      type
                    }
                  cursor
                  }
                  pageInfo {
                    endCursor
                    hasNextPage
                  }
                }
              }
            }
        """
        # loop while pagination has next page
        while result['data']['course']['enrollmentsConnection']['pageInfo']['hasNextPage']:
            after_cursor = result['data']['course']['enrollmentsConnection']['pageInfo']['endCursor']
            self.variables["after"] = after_cursor
            try:
                loop = asyncio.new_event_loop()
                asyncio.set_event_loop(loop)
                result = loop.run_until_complete(
                    self.client.execute_async(query=second_query, variables=self.variables))
                data = result["data"]["course"]["enrollmentsConnection"]["edges"]
                active_users_count += filter_enrollment_activity_by_date(data)
            except Exception as err:
                print("EnrollmentActivity error : {0}".format(err))
                raise

        yesterday = datetime.datetime.now() - datetime.timedelta(days=1)

        enrollment_activity['activity_date'] = yesterday
        enrollment_activity['active_users_count'] = active_users_count
        enrollment_activity['course_id'] = self.course_id
        enrollment_activity['course_name'] = result['data']['course']['name']

        print(enrollment_activity)
        # self.ingest_to_kpas(enrollment_activity)

    def fetch_enrollment_activity_restapi(self) -> Tuple[Dict]:
        url = "https://bibsys.instructure.com/api/v1/courses/{course_id}/enrollments?per_page=500".format(
            course_id=COURSE_ID)
        return self.paginate_through_url(url)

    def paginate_through_url(self, target_url):
        active_users_count = 0
        enrollment_activity = {}
        web_response = self.web_session.get(target_url)
        if web_response.status_code != 200:
            raise AssertionError("Could not retrieve data from Canvas LMS instance")
        new_items = json.loads(web_response.text)
        active_users_count += filter_enrollment_activity_by_date(new_items)
        while web_response.links.get('next'):
            next_page_url = web_response.links['next'].get('url')
            web_response = self.web_session.get(next_page_url)
            if web_response.status_code != 200:
                raise AssertionError("Could not retrieve data from Canvas LMS instance")
            new_items = json.loads(web_response.text)
            active_users_count += filter_enrollment_activity_by_date(new_items)

        yesterday = datetime.datetime.now() - datetime.timedelta(days=1)

        enrollment_activity['activity_date'] = yesterday
        enrollment_activity['active_users_count'] = active_users_count
        enrollment_activity['course_id'] = self.course_id

        print(enrollment_activity)


enrolment = EnrollmentActivity(access_token=CANVAS_ACCESS_KEY,
                               graphql_api_url=GRAPHQL_API_URL, course_id=COURSE_ID)
enrolment.fetch_enrollment_activity_restapi()
enrolment.fetch_enrollment_activity_graphql()
