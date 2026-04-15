using System.Configuration;
using System.Data.SqlClient;

namespace pow
{
    public class db
    {
        private readonly string conStr = ConfigurationManager.ConnectionStrings["DevDbConnection"].ConnectionString;

        public SqlConnection GetConnection()
        {
            return new SqlConnection(conStr);
        }
    }
}