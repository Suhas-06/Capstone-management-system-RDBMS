from flask import Flask, render_template, request, redirect, url_for , session
import pymysql
import matplotlib.pyplot as plt
import os
app = Flask(__name__, template_folder='')

# Replace these with your actual database credentials
server = 'localhost'
database = 'Universitydb'
username = 'root'
password = ''

static_dir = os.path.join(app.root_path, 'static')
os.makedirs(static_dir, exist_ok=True)

def get_table_columns(table_name):
    conn = pymysql.connect(
        host=server,
        user=username,
        password=password,
        database=database
    )

    cursor = conn.cursor()

    # Fetch column names from the table
    cursor.execute(f"SHOW COLUMNS FROM {table_name}")
    column_data = cursor.fetchall()
    column_names = [column[0] for column in column_data]

    cursor.close()
    conn.close()

    return column_names

@app.route('/admin_index')
def index():
    conn = pymysql.connect(
        host=server,
        user=username,
        password=password,
        database=database
    )

    cursor = conn.cursor()

    # Get a list of tables in your database
    cursor.execute("SHOW TABLES")
    table_data = cursor.fetchall()

    cursor.close()
    conn.close()

    table_names = [table[0] for table in table_data]

    return render_template('table_list.html', table_names=table_names)

@app.route('/display_table/<table_name>')
def display_table(table_name):
    conn = pymysql.connect(
        host=server,
        user=username,
        password=password,
        database=database
    )

    cursor = conn.cursor()
    cursor.execute(f"SHOW COLUMNS FROM {table_name}")
    column_data = cursor.fetchall()
    column_names = [column[0] for column in column_data]
    cursor.execute(f"SELECT * FROM {table_name}")

    results = cursor.fetchall()

    cursor.close()
    conn.close()

    return render_template('display_table.html', table_name=table_name, column_names=column_names, results=results)


from datetime import datetime
@app.route('/insert/<table_name>', methods=['GET', 'POST'])
def insert(table_name):
    #print("Insert view accessed")
    error_message = None
    if request.method == 'POST':
        data = request.form.to_dict()

        # Retrieve column names for the specified table
        conn = pymysql.connect(
            host=server,
            user=username,
            password=password,
            database=database
        )

        cursor = conn.cursor()

        # Fetch column names from the table
        cursor.execute(f"SHOW COLUMNS FROM {table_name}")
        column_data = cursor.fetchall()
        column_names = [column[0] for column in column_data]
        #print(column_names)
        
        # Check if 'DateOfBirth' is in the column_names
        if 'DateOfBirth' in column_names:
            date_of_birth = data.get('DateOfBirth')
            if date_of_birth:
                try:
                    # Parse the input date into a datetime object
                    date_of_birth = datetime.strptime(date_of_birth, '%d/%m/%Y')

                    # Format it as 'YYYY-MM-DD' for MySQL
                    data['DateOfBirth'] = date_of_birth.strftime('%Y-%m-%d')
                except ValueError:
                    # Handle invalid date format
                    return "Invalid date format. Please use 'DD/MM/YYYY'."
        #print(table_name)

        # Generate the SQL query with placeholders and values
        placeholders = ', '.join(['%s'] * len(column_names))
        insert_query = f"INSERT INTO {table_name} ({', '.join(column_names)}) VALUES ({placeholders})"
        values = [data.get(column_name) for column_name in column_names]
        #print("Insert query:", insert_query)
        #print("Values:", values)
        try:
            cursor.execute(insert_query, values)
            conn.commit()
        except pymysql.err.OperationalError as e:
            # Handle MySQL trigger error
            error_message = str(e)
        cursor.close()
        conn.close()
        if error_message:
            start_quote = error_message.find("'") + 1
            end_quote = error_message.find("'", start_quote)
            if start_quote != -1 and end_quote != -1:
                value_in_quotes = error_message[start_quote:end_quote]
            return render_template('error.html', error_message=value_in_quotes)
        return redirect(url_for('display_table', table_name=table_name))

    column_names = get_table_columns(table_name)
    return render_template('insert.html', table_name=table_name, column_names=column_names)


@app.route('/delete/<table_name>', methods=['GET', 'POST'])
def delete(table_name):
    if request.method == 'POST':
        selected_ids = request.form.getlist('delete_ids')

        if not selected_ids:
            return redirect(url_for('display_table', table_name=table_name))

        conn = pymysql.connect(
            host=server,
            user=username,
            password=password,
            database=database
        )

        cursor = conn.cursor()
        cursor.execute(f"SHOW COLUMNS FROM {table_name}")
        column_info = cursor.fetchone()
        first_column_name = column_info[0]
        # Delete the records with the selected IDs from the specified table
        delete_query = f"DELETE FROM {table_name} WHERE {first_column_name} IN ({', '.join(selected_ids)})"
        cursor.execute(delete_query)

        conn.commit()
        cursor.close()
        conn.close()

        return redirect(url_for('display_table', table_name=table_name))

    conn = pymysql.connect(
        host=server,
        user=username,
        password=password,
        database=database
    )

    cursor = conn.cursor()

    cursor.execute(f"SELECT * FROM {table_name}")

    results = cursor.fetchall()

    cursor.close()
    conn.close()

    return render_template('delete.html', table_name=table_name, results=results)

# Route to handle the update form submission
@app.route('/update/<table_name>', methods=['POST'])
def update(table_name):
    if request.method == 'POST':
        update_id = request.form.get('update_id')
        columns_to_update = request.form.getlist('columns_to_update[]')
        update_values = {}

        # Collect updated values from the form for the specified columns
        for column in columns_to_update:
            value = request.form.get(column)
            if value is not None:  # Check if the value is not null
                update_values[column] = value

        if not update_values:
            # No valid values to update, handle this case (e.g., display an error message)
            return redirect(url_for('display_table', table_name=table_name))

        conn = pymysql.connect(
            host=server,
            user=username,
            password=password,
            database=database
        )

        # Generate the update query for the specified columns
        with conn.cursor() as cursor:
            update_query = f"UPDATE {table_name} SET "
            update_query += ", ".join([f"{column} = '{update_values[column]}'" for column in columns_to_update])
            update_query += f" WHERE {table_name}ID = {update_id}"

            # Execute the update query
            cursor.execute(update_query)

        conn.commit()
        conn.close()

        # Redirect to the updated table
        return redirect(url_for('display_table', table_name=table_name))


@app.route('/show_charts')
def show_charts():
    conn = pymysql.connect(
        host=server,
        user=username,
        password=password,
        database=database
    )

    cursor = conn.cursor()

    # Query for Domain counts
    cursor.execute("SELECT Domain, COUNT(*) AS DomainCount FROM Project GROUP BY Domain")
    domain_data = cursor.fetchall()
    domain_labels, domain_counts = zip(*domain_data)

    # Query for Status counts
    cursor.execute("SELECT Status, COUNT(*) AS StatusCount FROM Project GROUP BY Status")
    status_data = cursor.fetchall()
    status_labels, status_counts = zip(*status_data)

    cursor.close()
    conn.close()

    # Create a pie chart for Domain counts
    plt.figure(figsize=(8, 4))
    plt.pie(domain_counts, labels=domain_labels, autopct='%1.1f%%', startangle=140)
    plt.axis('equal')
    plt.title('Project Domain Distribution')
    plt.savefig('static/domain_pie_chart.png')
    plt.clf()

    # Create a bar chart for Status counts
    plt.figure(figsize=(8, 6))
    plt.bar(status_labels, status_counts)
    plt.xlabel('Project Status')
    plt.ylabel('Count')
    plt.title('Project Status Distribution')
    plt.xticks(rotation=45)
    plt.tight_layout()
    plt.savefig('static/status_bar_chart.png')
    plt.clf()

    return render_template('show_charts.html')

def execute_team_info_query(team_id):
    conn = pymysql.connect(
        host=server,
        user=username,
        password=password,
        database=database
    )

    cursor = conn.cursor()

    # Your SQL query
    query = """
    SELECT
        Team.TeamID,
        Project.Title AS ProjectTitle,
        Project.Domain AS ProjectDomain,
        Project.Status AS ProjectStatus,
        Mentor.FirstName AS MentorFirstName,
        Mentor.LastName AS MentorLastName,
        Mentor.Email AS MentorEmail,
        GROUP_CONCAT(CONCAT(Student.FirstName, ' ', Student.LastName) ORDER BY Student.StudentID ASC) AS StudentNames,
        GROUP_CONCAT(Grades.Grade ORDER BY Student.StudentID ASC) AS StudentGrades,
        Mentor.status AS Status
    FROM Team
    INNER JOIN Project ON Team.ProjectID = Project.ProjectID
    INNER JOIN Mentor ON Team.MentorID = Mentor.MentorID
    LEFT JOIN TeamStudent ON Team.TeamID = TeamStudent.TeamID
    LEFT JOIN Student ON TeamStudent.StudentID = Student.StudentID
    LEFT JOIN Grades ON TeamStudent.StudentID = Grades.StudentID AND Project.ProjectID = Grades.ProjectID
    WHERE Team.TeamID = %s
    GROUP BY Team.TeamID;
    """

    # Execute the query with the provided team_id
    cursor.execute(query, (team_id,))

    # Fetch the results
    result = cursor.fetchall()

    cursor.close()
    conn.close()

    return result

def get_team_ids():
    conn = pymysql.connect(
        host=server,
        user=username,
        password=password,
        database=database
    )

    cursor = conn.cursor()

    # SQL query to fetch team IDs
    query = "SELECT TeamID FROM Team"

    cursor.execute(query)

    team_ids = [row[0] for row in cursor.fetchall()]
    #print(team_ids)
    cursor.close()
    conn.close()

    return team_ids

def calculate_average_cgpa(team_id):
    conn = pymysql.connect(
        host=server,
        user=username,
        password=password,
        database=database
    )

    cursor = conn.cursor()

    # Directly substitute team_id into the query (not recommended for user input)
    query = f"""
        SELECT AVG(Student.CGPA) AS AverageCGPA
        FROM Student
        JOIN TeamStudent ON Student.StudentID = TeamStudent.StudentID
        WHERE TeamStudent.TeamID = {team_id}
        GROUP BY TeamStudent.TeamID
    """

    cursor.execute(query)

    average_cgpa = cursor.fetchone()

    cursor.close()
    conn.close()

    return average_cgpa[0] if average_cgpa else None


@app.route('/team_info', methods=['GET', 'POST'])
def team_info():
    if request.method == 'POST':
        team_id = int(request.form.get('team_id'))
        team_info_result = execute_team_info_query(team_id)
        #print(team_info_result)
        average_cgpa = calculate_average_cgpa(team_id)
        return render_template('team_info.html', team_ids=get_team_ids(), team_info=team_info_result, average_cgpa=average_cgpa)

    team_ids = get_team_ids()
    return render_template('team_info.html', team_ids=team_ids)





@app.route('/')
def new_index():
    return render_template('dashboard.html')

users = {
    'student': {'password': 'student123', 'role': 'student'},
    'mentor': {'password': 'mentor456', 'role': 'mentor'},
    'admin': {'password': 'admin789', 'role': 'admin'}
}

# Create a secret key for the session
app.secret_key = 'super_secret_key'

@app.route('/choose_role', methods=['POST'])
def choose_role():
    username = request.form['username']
    password = request.form['password']

    if users.get(username) and users[username]['password'] == password:
        session['username'] = username
        return redirect(url_for(f"{users[username]['role']}_dashboard"))
    else:
        return "Invalid credentials. Please try again."

# Dashboard routes for different roles
@app.route('/student_dashboard')
def student_dashboard():
    # Assuming you have a dictionary named 'users' with user information
    # and a list of table names available in your database
    if session.get('username') and users.get(session['username'], {}).get('role') == 'student':
        conn = pymysql.connect(
            host=server,
            user=username,
            password=password,
            database=database
        )

        cursor = conn.cursor()

        # Get a list of tables in your database
        cursor.execute("SHOW TABLES")
        table_data = cursor.fetchall()

        cursor.close()
        conn.close()

        table_names = [table[0] for table in table_data]

        # Assuming you have tables named 'grades' and 'review'
        # Display only these tables on the student dashboard
        display_tables = ['grades', 'review']

        # Filter the tables to display only those in 'display_tables'
        filtered_tables = [table for table in table_names if table in display_tables]

        return render_template('student_dashboard.html', table_names=filtered_tables)
    else:
        return "Unauthorized access."

@app.route('/mentor_dashboard')
def mentor_dashboard():
    if session.get('username') and users[session['username']]['role'] == 'mentor':
        return render_template('mentor_dashboard.html')
    else:
        return "Unauthorized access."

@app.route('/admin_dashboard')
def admin_dashboard():
    if session.get('username') and users[session['username']]['role'] == 'admin':
        conn = pymysql.connect(
        host=server,
        user=username,
        password=password,
        database=database
        )

        cursor = conn.cursor()

        # Get a list of tables in your database
        cursor.execute("SHOW TABLES")
        table_data = cursor.fetchall()

        cursor.close()
        conn.close()

        table_names = [table[0] for table in table_data]

        return render_template('table_list.html',table_names=table_names)
    else:
        return "Unauthorized access."
    
# Assuming you have a function to fetch data from the specified table
def get_table_data(table_name):
    conn = pymysql.connect(
        host=server,
        user=username,
        password=password,
        database=database
    )

    cursor = conn.cursor()

    # Assuming a simple SELECT query for demonstration purposes
    cursor.execute(f"SELECT * FROM {table_name}")
    table_data = cursor.fetchall()

    cursor.close()
    conn.close()

    return table_data

@app.route('/table_view/<table_name>')
def table_view(table_name):
    # Retrieve data from the specified table
    conn = pymysql.connect(
        host=server,
        user=username,
        password=password,
        database=database
        )
    cursor = conn.cursor()
    if table_name == 'grades':
        cursor.execute('''
        SELECT
        student.StudentID,
        CONCAT(student.FirstName, ' ', COALESCE(student.MiddleName, ''), ' ', student.LastName) AS 'Student name',
        project.Title AS 'Project title',
        grades.grade AS 'Grade'
        FROM
        grades
        JOIN
        student ON grades.studentID = student.studentID
        JOIN
        project ON grades.ProjectID = Project.ProjectID
        ''')
        table_data = cursor.fetchall()
        column_names = [column[0] for column in cursor.description]
    else:
        table_data = get_table_data(table_name)
        cursor.execute(f"SHOW COLUMNS FROM {table_name}")
        column_data = cursor.fetchall()
        column_names = [column[0] for column in column_data]
    cursor.close()
    conn.close()
    return render_template('table_view.html', table_name=table_name, table_data=table_data,column_names=column_names)

@app.route('/mentor_view/<table_name>')
def mentor_view(table_name):
    # Assuming you have tables named 'mentor', 'project', 'panel', 'review'
    # Display only the specified table on the mentor dashboard
    conn = pymysql.connect(
        host=server,
        user=username,
        password=password,
        database=database
    )
    display_tables = ['mentor', 'team', 'panel', 'project']

    if table_name in display_tables:
        # Get data for the specified table
        table_data = {table_name: get_table_data(table_name)}
        cursor = conn.cursor()
        cursor.execute(f"SHOW COLUMNS FROM {table_name}")
        column_data = cursor.fetchall()
        column_names = [column[0] for column in column_data]
        cursor.close()
        conn.close()
        # Render mentor_view.html with the table data
        return render_template('mentor_view.html', column_names=column_names, table_name=table_name, tables=table_data, allow_cud=False)
    else:
        return "Invalid table name."


@app.route('/approve')
def approve():
    conn = pymysql.connect(
        host=server,
        user=username,
        password=password,
        database=database
        )
    cursor = conn.cursor()
    # SQL query
    query = '''
    SELECT
        Mentor.MentorID AS 'Mentor ID',
        CONCAT(Mentor.FirstName, ' ', COALESCE(Mentor.MiddleName, ''), ' ', Mentor.LastName) AS 'Mentor Name',
        Mentor.TeamID AS 'Team ID',
        Project.Title AS 'Project Title',
        Project.Domain AS 'Domain',
        Mentor.Status  -- Include the Status column in the SELECT clause
    FROM
        Mentor
    JOIN
        Project ON Mentor.TeamID = Project.TeamID;
'''
    # Execute the query
    cursor.execute(query)
    table_data=cursor.fetchall()
    column_names = [column[0] for column in cursor.description]
    return render_template('approve.html', table_data=table_data,column_names=column_names)

@app.route('/update_status', methods=['POST'])
def update_status():
    if request.method == 'POST':
        conn = pymysql.connect(
            host=server,
            user=username,
            password=password,
            database=database
        )
        cursor = conn.cursor()
        
        for mentor_id, new_status in request.form.items():
            if mentor_id.startswith("new_status_"):
                mentor_id = mentor_id.replace("new_status_", "")
                
                # Update the status in the mentor table
                update_query = "UPDATE Mentor SET Status = %s WHERE MentorID = %s"
                cursor.execute(update_query, (new_status, mentor_id))
                
        conn.commit()
        cursor.close()
        conn.close()
        
        # Redirect back to the approve page
        return redirect(url_for('approve'))
    

if __name__ == '__main__':
    app.run()
