import java.sql.*;
// Проверка подключения к базе данных

public class Test {
  public static void main(String[] args)
      throws SQLException {
    Connection conn = DriverManager.getConnection(
        "jdbc:postgresql://localhost:5432/appdb",
        "app", "p@ssw0rd");
    Statement st = conn.createStatement();
    ResultSet rs = st.executeQuery(
        "SELECT * FROM greeting");
    while (rs.next()) {
      System.out.println(rs.getString(1));
    }
    rs.close();
    st.close();
    conn.close();
  }
}
