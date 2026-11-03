//+------------------------------------------------------------------+
//|                                                          Sql.mqh |
//|                        Copyright 2026, wwwgzpucom | Exness |
//|                     https://one.toexness.com/intl/zh/a/30852 |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2026, wwwgzpucom | Exness https://one.toexness.com/intl/zh/a/30852"
#property link        "https://one.toexness.com/intl/zh/a/30852"
#property version   "1.0"

//+------------------------------------------------------------------+
//| Fetch the query result as a matrix (double type).                |
//+------------------------------------------------------------------+
bool SqlSelect(int db, const string sql, matrix &m, string &head[]) {
    int nrows, ncols;
    int dp;
    double val;
    string sval;

    dp = DatabasePrepare(db, sql);
    if (dp == INVALID_HANDLE) {
        PrintFormat("Error (%s, DatabasePrepare): #%d", __FUNCTION__, GetLastError());
        return false;
    }

    nrows = 0;
    ncols = DatabaseColumnsCount(dp);
    m.Init(nrows, ncols);
    ArrayResize(head, ncols);

    while (DatabaseRead(dp) && !IsStopped()) {
        m.Resize(nrows + 1, ncols);
        for (int j = 0; j < ncols && !IsStopped(); j++) {
            if (nrows == 0) {
                sval = "";
                DatabaseColumnName(dp, j, sval);
                head[j] = sval;
            }

            if (!DatabaseColumnDouble(dp, j, val)) {
                PrintFormat("Error (%s, DatabaseColumnDouble): #%d", __FUNCTION__, GetLastError());
                DatabaseFinalize(dp);
                return false;
            }
            m[nrows][j] = val;
        }
        nrows++;
    }

    DatabaseFinalize(dp);
    return true;
}

//+------------------------------------------------------------------+
//| Fetch the query result as a array of strings.                    |
//+------------------------------------------------------------------+
bool SqlSelect(int db, const string sql, string &rows[], string &head[], const ushort sep = '\t') {
    int nrows, ncols;
    int dp;
    double dval;
    long lval;
    string sval;

    dp = DatabasePrepare(db, sql);
    if (dp == INVALID_HANDLE) {
        PrintFormat("Error (%s, DatabasePrepare): #%d", __FUNCTION__, GetLastError());
        return false;
    }

    nrows = 0;
    ncols = DatabaseColumnsCount(dp);
    ArrayResize(head, ncols);

    while (DatabaseRead(dp) && !IsStopped()) {
        string row = "";
        for (int j = 0; j < ncols && !IsStopped(); j++) {
            if (nrows == 0) {
                sval = "";
                DatabaseColumnName(dp, j, sval);
                head[j] = sval;
            }

            ENUM_DATABASE_FIELD_TYPE ct = DatabaseColumnType(dp, j);
            dval = 0;
            lval = 0;
            sval = "";
            if (StringLen(row) > 0)
                StringAdd(row, StringFormat("%c", sep));
            if (ct == DATABASE_FIELD_TYPE_FLOAT) {
                DatabaseColumnDouble(dp, j, dval);
                StringAdd(row, (string) dval);
            } else if (ct == DATABASE_FIELD_TYPE_INTEGER) {
                DatabaseColumnLong(dp, j, lval);
                StringAdd(row, (string) lval);
            } else if (ct == DATABASE_FIELD_TYPE_TEXT) {
                DatabaseColumnText(dp, j, sval);
                StringAdd(row, sval);
            }
        }
        ArrayResize(rows, nrows + 1);
        rows[nrows] = row;
        nrows++;
    }

    DatabaseFinalize(dp);
    return true;
}

//+------------------------------------------------------------------+
//| Overload                                                         |
//+------------------------------------------------------------------+
bool SqlSelect(int db, const string sql, matrix &m) {
    string head[];
    return SqlSelect(db, sql, m, head);
}

//+------------------------------------------------------------------+
//| Overload                                                         |
//+------------------------------------------------------------------+
bool SqlSelect(int db, const string sql, string &rows[], const ushort sep = '\t') {
    string head[];
    return SqlSelect(db, sql, rows, head, sep);
}

//+------------------------------------------------------------------+
//| Returns the first value of the query result.                     |
//+------------------------------------------------------------------+
long SqlGetLong(int db, const string sql, long default_value = -1) {
    matrix m;
    if (!SqlSelect(db, sql, m)) return default_value;
    return (long) m[0][0];
}

//+------------------------------------------------------------------+
//| Returns the first value of the query result.                     |
//+------------------------------------------------------------------+
double SqlGetDouble(int db, const string sql, double default_value = -1) {
    matrix m;
    if (!SqlSelect(db, sql, m)) return default_value;
    return (double) m[0][0];
}

//+------------------------------------------------------------------+
//| Returns the first value of the query result.                     |
//+------------------------------------------------------------------+
string SqlGetString(int db, const string sql, string default_value = "") {
    string rows[], row[];
    if (!SqlSelect(db, sql, rows, '¡')) return default_value;
    if (ArraySize(rows) < 1) return default_value;
    int n = StringSplit(rows[0], '¡', row);
    if (n < 1) return default_value;
    return row[0];
}

//+------------------------------------------------------------------+
