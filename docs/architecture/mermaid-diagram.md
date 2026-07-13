flowchart TB

%% =========================================================
%% VISUAL THEME
%% =========================================================

classDef frontend fill:#E8F1FF,stroke:#3B82F6,stroke-width:2px,color:#172554;
classDef translation fill:#F3E8FF,stroke:#8B5CF6,stroke-width:2px,color:#3B0764;
classDef canonical fill:#FFF7D6,stroke:#D97706,stroke-width:2px,color:#451A03;
classDef validation fill:#FCE7F3,stroke:#DB2777,stroke-width:2px,color:#500724;
classDef planning fill:#FFEDD5,stroke:#EA580C,stroke-width:2px,color:#431407;
classDef execution fill:#DCFCE7,stroke:#16A34A,stroke-width:2px,color:#052E16;
classDef catalog fill:#E0F2FE,stroke:#0284C7,stroke-width:2px,color:#082F49;
classDef storage fill:#CCFBF1,stroke:#0F766E,stroke-width:2px,color:#042F2E;
classDef result fill:#F1F5F9,stroke:#475569,stroke-width:2px,color:#0F172A;
classDef diagnostic fill:#FEE2E2,stroke:#DC2626,stroke-width:2px,color:#450A0A;
classDef runtime fill:#EDE9FE,stroke:#7C3AED,stroke-width:3px,color:#2E1065;
classDef editor fill:#FAE8FF,stroke:#C026D3,stroke-width:2px,color:#4A044E;
classDef future fill:#FFFFFF,stroke:#94A3B8,stroke-width:2px,stroke-dasharray:6 4,color:#475569;



    subgraph Frontends["Query Frontends"]
        SQLInput["SQL Text"]
        FluentAPI["Fluent Query API"]
        GraphInput["Query Graph"]
        FutureFrontend["Future Frontend"]
    end

    subgraph SQL["SQL Translation"]
        SqlLexer["SqlLexer"]
        SqlToken["SqlToken"]
        TokenizationResult["TokenizationResult"]

        SqlParser["SqlParser"]
        SqlParseResult["SqlParseResult"]

        SqlStatement["SqlStatement"]
        SqlSelectStatement["SqlSelectStatement"]
        SqlColumnNode["SqlColumnNode"]
        SqlTableNode["SqlTableNode"]
        SqlBinaryExpressionNode["SqlBinaryExpressionNode"]
        SqlLiteralNode["SqlLiteralNode"]

        SqlQueryCompiler["SqlQueryCompiler"]
        QueryCompilationResult["QueryCompilationResult"]
    end

    subgraph Fluent["Fluent Construction"]
        Query["Query"]
        SelectQueryBuilder["SelectQueryBuilder"]
        InsertQueryBuilder["InsertQueryBuilder"]
    end

    subgraph Graph["Graph Translation"]
        QueryGraph["QueryGraph"]
        GraphQueryCompiler["GraphQueryCompiler"]
    end

    subgraph Canonical["Canonical Query Model"]
        QuerySpec["QuerySpec"]

        SelectQuerySpec["SelectQuerySpec"]
        InsertQuerySpec["InsertQuerySpec"]
        UpdateQuerySpec["UpdateQuerySpec"]
        DeleteQuerySpec["DeleteQuerySpec"]

        QuerySpecVisitor["QuerySpecVisitor"]

        QuerySource["QuerySource"]
        TableReference["TableReference"]
        JoinSpec["JoinSpec"]
        InsertRow["InsertRow"]
        ColumnAssignment["ColumnAssignment"]
        OrderClause["OrderClause"]
        SortDirection["SortDirection"]
    end

    subgraph Expressions["Expression Model"]
        QueryExpression["QueryExpression"]
        ExpressionVisitor["ExpressionVisitor"]

        ColumnExpression["ColumnExpression"]
        LiteralExpression["LiteralExpression"]
        ComparisonExpression["ComparisonExpression"]
        LogicalExpression["LogicalExpression"]
        FunctionExpression["FunctionExpression"]

        ComparisonOperator["ComparisonOperator"]
        LogicalOperator["LogicalOperator"]
    end

    subgraph Validation["Validation and Binding"]
        QueryValidator["QueryValidator"]
        DefaultQueryValidator["DefaultQueryValidator"]
        QueryValidationResult["QueryValidationResult"]

        BoundQuery["BoundQuery"]
        BoundSelectQuery["BoundSelectQuery"]
        BoundInsertQuery["BoundInsertQuery"]
        BoundQueryOperation["BoundQueryOperation"]
        BoundColumnExpression["BoundColumnExpression"]

        TableId["TableId"]
        ColumnId["ColumnId"]
    end

    subgraph Planning["Query Planning"]
        QueryPlanner["QueryPlanner"]
        QueryPlan["QueryPlan"]

        PlanNode["PlanNode"]
        PlanNodeVisitor["PlanNodeVisitor"]

        TableScanPlan["TableScanPlan"]
        PrimaryKeyLookupPlan["PrimaryKeyLookupPlan"]
        FilterPlan["FilterPlan"]
        ProjectionPlan["ProjectionPlan"]
        AggregatePlan["AggregatePlan"]
        SortPlan["SortPlan"]
        LimitPlan["LimitPlan"]
        InsertPlan["InsertPlan"]
    end

    subgraph Execution["Query Execution"]
        QueryExecutor["QueryExecutor"]
        DefaultQueryExecutor["DefaultQueryExecutor"]
        ExecutionContext["ExecutionContext"]

        ExpressionEvaluator["ExpressionEvaluator"]
        QueryFunctionRegistry["QueryFunctionRegistry"]
        QueryCancellationToken["QueryCancellationToken"]
        TransactionManager["TransactionManager"]
    end

    subgraph Catalog["Catalog"]
        CatalogService["CatalogService"]
        CatalogSnapshot["CatalogSnapshot"]

        DatabaseDefinition["DatabaseDefinition"]
        TableDefinition["TableDefinition"]
        ColumnDefinition["ColumnDefinition"]
        IndexDefinition["IndexDefinition"]
    end

    subgraph Storage["Storage"]
        TableStorage["TableStorage"]
        ConfigFileTableStorage["ConfigFileTableStorage"]

        StorageSession["StorageSession"]
        TableSnapshot["TableSnapshot"]
        RowRecord["RowRecord"]

        DatabasePathResolver["DatabasePathResolver"]
        ConfigFileCache["ConfigFileCache"]
        GodotVariantCodec["GodotVariantCodec"]

        FutureStorage["Future Storage Backend"]
    end

    subgraph Results["Results and Materialization"]
        RowSet["RowSet"]
        ResultSchema["ResultSchema"]
        ResultMapping["ResultMapping"]

        ResultMaterializer["ResultMaterializer"]
        DictionaryResultMaterializer["DictionaryResultMaterializer"]
        ResourceResultMaterializer["ResourceResultMaterializer"]
        ModelResultMaterializer["ModelResultMaterializer"]
        EditorTableMaterializer["EditorTableMaterializer"]
        CsvExportMaterializer["CsvExportMaterializer"]

        QueryResult["QueryResult"]
    end

    subgraph Diagnostics["Diagnostics"]
        QueryDiagnostic["QueryDiagnostic"]
        SourceSpan["SourceSpan"]

        OperationResult["OperationResult"]
        QueryExecutionResult["QueryExecutionResult"]
        QueryPlanningResult["QueryPlanningResult"]
        StorageOperationResult["StorageOperationResult"]
        StorageCommitResult["StorageCommitResult"]
    end

    subgraph Runtime["Runtime Facade"]
        Database["Database"]
        DatabaseContext["DatabaseContext"]
        GDSQLRuntimeFactory["GDSQLRuntimeFactory"]
    end

    subgraph Editor["Editor"]
        EditorBoundary["Editor Tools"]
    end



    SQLInput --> SqlLexer
    SqlLexer --> TokenizationResult
    TokenizationResult --> SqlToken
    TokenizationResult --> SqlParser
    SqlParser --> SqlParseResult
    SqlParseResult --> SqlStatement
    SqlStatement --> SqlSelectStatement

    SqlSelectStatement --> SqlColumnNode
    SqlSelectStatement --> SqlTableNode
    SqlSelectStatement --> SqlBinaryExpressionNode
    SqlBinaryExpressionNode --> SqlLiteralNode

    SqlParseResult --> SqlQueryCompiler
    SqlQueryCompiler --> QueryCompilationResult
    QueryCompilationResult --> QuerySpec

    FluentAPI --> Query
    Query --> SelectQueryBuilder
    SelectQueryBuilder --> QuerySpec
    Query --> InsertQueryBuilder
    InsertQueryBuilder --> InsertQuerySpec

    GraphInput --> QueryGraph
    QueryGraph --> GraphQueryCompiler
    GraphQueryCompiler --> QuerySpec

    FutureFrontend -.-> QuerySpec

    QuerySpec --> SelectQuerySpec
    QuerySpec --> InsertQuerySpec
    QuerySpec --> UpdateQuerySpec
    QuerySpec --> DeleteQuerySpec
    QuerySpec --> QuerySpecVisitor

    SelectQuerySpec --> QuerySource
    QuerySource --> TableReference
    SelectQuerySpec --> JoinSpec
    SelectQuerySpec --> OrderClause
    InsertQuerySpec --> InsertRow
    UpdateQuerySpec --> ColumnAssignment
    InsertQuerySpec --> TableReference
    UpdateQuerySpec --> TableReference
    DeleteQuerySpec --> TableReference
    OrderClause --> SortDirection

    QueryExpression --> ColumnExpression
    QueryExpression --> LiteralExpression
    QueryExpression --> ComparisonExpression
    QueryExpression --> LogicalExpression
    QueryExpression --> FunctionExpression
    QueryExpression --> ExpressionVisitor

    ComparisonExpression --> ComparisonOperator
    LogicalExpression --> LogicalOperator

    SelectQuerySpec --> QueryExpression
    JoinSpec --> QueryExpression
    ColumnAssignment --> QueryExpression
    OrderClause --> QueryExpression

    QuerySpec --> QueryValidator
    QueryValidator --> DefaultQueryValidator
    DefaultQueryValidator --> CatalogSnapshot
    DefaultQueryValidator --> QueryValidationResult

    QueryValidationResult --> BoundQuery
    BoundQuery --> BoundQueryOperation
    BoundQueryOperation --> BoundSelectQuery
    BoundQueryOperation --> BoundInsertQuery
    BoundQuery --> BoundColumnExpression
    BoundColumnExpression --> ExpressionVisitor
    BoundColumnExpression --> TableId
    BoundColumnExpression --> ColumnId

    BoundQuery --> QueryPlanner
    QueryPlanner --> QueryPlanningResult
    QueryPlanningResult --> QueryPlan
    QueryPlan --> PlanNode

    PlanNode --> TableScanPlan
    PlanNode --> PrimaryKeyLookupPlan
    PlanNode --> FilterPlan
    PlanNode --> ProjectionPlan
    PlanNode --> AggregatePlan
    PlanNode --> SortPlan
    PlanNode --> LimitPlan
    PlanNode --> InsertPlan
    PlanNode --> PlanNodeVisitor

    QueryPlan --> QueryExecutor
    QueryExecutor --> DefaultQueryExecutor
    DefaultQueryExecutor --> ExecutionContext
    ExecutionContext --> CatalogService
    ExecutionContext --> TableStorage
    ExecutionContext --> TransactionManager
    ExecutionContext --> ExpressionEvaluator
    ExecutionContext --> QueryFunctionRegistry
    ExecutionContext --> QueryCancellationToken

    CatalogService --> CatalogSnapshot
    CatalogSnapshot --> DatabaseDefinition
    DatabaseDefinition --> TableDefinition
    TableDefinition --> ColumnDefinition
    TableDefinition --> IndexDefinition

    TableStorage --> ConfigFileTableStorage
    TableStorage -.-> FutureStorage
    ConfigFileTableStorage --> StorageSession
    ConfigFileTableStorage --> TableSnapshot
    TableSnapshot --> RowRecord
    ConfigFileTableStorage --> DatabasePathResolver
    ConfigFileTableStorage --> ConfigFileCache
    ConfigFileTableStorage --> GodotVariantCodec

    DefaultQueryExecutor --> QueryExecutionResult
    QueryExecutionResult --> RowSet
    RowSet --> RowRecord
    RowSet --> ResultSchema

    ResultMaterializer --> ResultMapping
    ResultMaterializer --> DictionaryResultMaterializer
    ResultMaterializer --> ResourceResultMaterializer
    ResultMaterializer --> ModelResultMaterializer
    ResultMaterializer --> EditorTableMaterializer
    ResultMaterializer --> CsvExportMaterializer
    RowSet --> ResultMaterializer
    ResultMaterializer --> QueryResult

    QueryDiagnostic --> SourceSpan
    OperationResult --> QueryDiagnostic
    QueryValidationResult --> QueryDiagnostic
    QueryPlanningResult --> QueryDiagnostic
    QueryExecutionResult --> QueryDiagnostic
    StorageOperationResult --> QueryDiagnostic
    StorageCommitResult --> QueryDiagnostic

    Database --> DatabaseContext
    DatabaseContext --> QueryValidator
    DatabaseContext --> QueryPlanner
    DatabaseContext --> QueryExecutor
    DatabaseContext --> ResultMaterializer

    GDSQLRuntimeFactory --> DatabaseContext
    GDSQLRuntimeFactory --> CatalogService
    GDSQLRuntimeFactory --> TableStorage
    GDSQLRuntimeFactory --> QueryValidator
    GDSQLRuntimeFactory --> QueryPlanner
    GDSQLRuntimeFactory --> QueryExecutor

    EditorBoundary --> Database
    EditorBoundary --> QueryGraph
    EditorBoundary --> QueryResult
    EditorBoundary --> QueryDiagnostic

%% SQL translation: edges 0–13
linkStyle 0,1,2,3,4,5,6,7,8,9,10,11,12,13 stroke:#8B5CF6,stroke-width:2.5px;

%% Fluent API: edges 14–16
linkStyle 14,15,16 stroke:#3B82F6,stroke-width:2.5px;

%% Graph frontend: edges 17–19
linkStyle 17,18,19 stroke:#C026D3,stroke-width:2.5px;

%% Future frontend extension: edge 20
linkStyle 20 stroke:#94A3B8,stroke-width:2px,stroke-dasharray:6 4;

%% Canonical QuerySpec model: edges 21–35
linkStyle 21,22,23,24,25,26,27,28,29,30,31,32,33,34,35 stroke:#D97706,stroke-width:2px;

%% Expression model: edges 36–47
linkStyle 36,37,38,39,40,41,42,43,44,45,46,47 stroke:#CA8A04,stroke-width:2px;

%% Validation and binding: edges 48–57
linkStyle 48,49,50,51,52,53,54,55,56,57 stroke:#DB2777,stroke-width:2.5px;

%% Planning: edges 58–69
linkStyle 58,59,60,61,62,63,64,65,66,67,68,69 stroke:#EA580C,stroke-width:2.5px;

%% Execution: edges 70–78
linkStyle 70,71,72,73,74,75,76,77,78 stroke:#16A34A,stroke-width:2.5px;

%% Catalog: edges 79–83
linkStyle 79,80,81,82,83 stroke:#0284C7,stroke-width:2px;

%% Storage: edges 84–91
linkStyle 84,86,87,88,89,90,91 stroke:#0F766E,stroke-width:2.5px;

%% Future storage extension: edge 85
linkStyle 85 stroke:#94A3B8,stroke-width:2px,stroke-dasharray:6 4;

%% Execution output: edges 92–95
linkStyle 92,93,94,95 stroke:#16A34A,stroke-width:2px;

%% Result materialization: edges 96–103
linkStyle 96,97,98,99,100,101,102,103 stroke:#475569,stroke-width:2.5px;

%% Diagnostics: edges 104–110
linkStyle 104,105,106,107,108,109,110 stroke:#DC2626,stroke-width:1.8px;

%% Runtime facade: edges 111–121
linkStyle 111,112,113,114,115,116,117,118,119,120,121 stroke:#7C3AED,stroke-width:2.5px;

%% Editor boundary: edges 122–125
linkStyle 122,123,124,125 stroke:#C026D3,stroke-width:2px;


%% Frontends
class SQLInput,FluentAPI,GraphInput frontend;
class FutureFrontend future;

%% SQL, fluent, and graph translation
class SqlLexer,SqlToken,TokenizationResult translation;
class SqlParser,SqlParseResult,SqlStatement,SqlSelectStatement translation;
class SqlColumnNode,SqlTableNode,SqlBinaryExpressionNode,SqlLiteralNode translation;
class SqlQueryCompiler,QueryCompilationResult translation;
class Query,SelectQueryBuilder,InsertQueryBuilder,QueryGraph,GraphQueryCompiler translation;

%% Canonical query and expression models
class QuerySpec,SelectQuerySpec,InsertQuerySpec,UpdateQuerySpec,DeleteQuerySpec canonical;
class QuerySpecVisitor,QuerySource,TableReference,JoinSpec canonical;
class InsertRow,ColumnAssignment,OrderClause,SortDirection canonical;
class QueryExpression,ExpressionVisitor,ColumnExpression,LiteralExpression canonical;
class ComparisonExpression,LogicalExpression,FunctionExpression canonical;
class ComparisonOperator,LogicalOperator canonical;

%% Validation and binding
class QueryValidator,DefaultQueryValidator,QueryValidationResult validation;
class BoundQuery,BoundSelectQuery,BoundInsertQuery,BoundQueryOperation validation;
class BoundColumnExpression,TableId,ColumnId validation;

%% Planning
class QueryPlanner,QueryPlanningResult,QueryPlan planning;
class PlanNode,PlanNodeVisitor,TableScanPlan,PrimaryKeyLookupPlan planning;
class FilterPlan,ProjectionPlan,AggregatePlan,SortPlan,LimitPlan,InsertPlan planning;

%% Execution
class QueryExecutor,DefaultQueryExecutor,ExecutionContext execution;
class ExpressionEvaluator,QueryFunctionRegistry,QueryCancellationToken execution;
class TransactionManager,QueryExecutionResult execution;

%% Catalog
class CatalogService,CatalogSnapshot catalog;
class DatabaseDefinition,TableDefinition,ColumnDefinition,IndexDefinition catalog;

%% Storage
class TableStorage,ConfigFileTableStorage storage;
class StorageSession,TableSnapshot,RowRecord storage;
class DatabasePathResolver,ConfigFileCache,GodotVariantCodec storage;
class FutureStorage future;

%% Results
class RowSet,ResultSchema,ResultMapping result;
class ResultMaterializer,DictionaryResultMaterializer result;
class ResourceResultMaterializer,ModelResultMaterializer result;
class EditorTableMaterializer,CsvExportMaterializer,QueryResult result;

%% Diagnostics
class QueryDiagnostic,SourceSpan,OperationResult diagnostic;
class QueryPlanningResult,StorageOperationResult,StorageCommitResult diagnostic;

%% Runtime and editor
class Database,DatabaseContext,GDSQLRuntimeFactory runtime;
class EditorBoundary editor;
