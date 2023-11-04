CREATE TABLE curso (
    id_curso INT AUTO_INCREMENT PRIMARY KEY,
    nome_curso VARCHAR(255),
    duracao INT,
    mensalidade INT,
    area VARCHAR(255)
);

CREATE TABLE aluno (
    id_aluno INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(255),
    sobreNome VARCHAR(255),
    email VARCHAR(255),
    id_curso INT,
    status_matricula VARCHAR(255),
    FOREIGN KEY (id_curso) REFERENCES curso(id_curso)
);

DELIMITER //

CREATE PROCEDURE InserirCursosAutomaticamente()
BEGIN
    DECLARE i INT DEFAULT 1;
    WHILE i <= 5 DO
        INSERT INTO curso (nome_curso, duracao, mensalidade, area)
        VALUES (CONCAT('Curso ', i), i * 2, i * 100, CONCAT('Área ', i));
        
        SET i = i + 1;
    END WHILE;
END;
//

DELIMITER ;

CALL InserirCursosAutomaticamente();

DELIMITER //

CREATE PROCEDURE EntraAlunosAutomaticamente()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE curso_id INT;  -- Mova a declaração fora do loop

    WHILE i <= 5 DO
        SELECT id_curso INTO curso_id FROM curso WHERE nome_curso = CONCAT('Curso ', i);
        
        IF curso_id IS NOT NULL THEN
            INSERT INTO aluno (nome, sobreNome, email, id_curso, status_matricula)
            VALUES ('Aluno', i, CONCAT('aluno', i, '.', i, '@dominio.com'), curso_id, 'NAO MATRICULADO');
        ELSE
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Curso não encontrado.';
        END IF;
        
        SET i = i + 1;
    END WHILE;
END;
//

DELIMITER ;

CALL EntraAlunosAutomaticamente();


DELIMITER //

CREATE PROCEDURE AtualizarStatusMatriculaAluno(
    IN alunoId INT,
    IN nomeCurso VARCHAR(255),
    IN areaCurso VARCHAR(255)
)
BEGIN
    DECLARE cursoId INT;
    SELECT id_curso INTO cursoId FROM curso WHERE nome_curso = nomeCurso AND area = areaCurso;
    
    IF cursoId IS NOT NULL THEN
        UPDATE aluno
        SET status_matricula = 'Matriculado', id_curso = cursoId
        WHERE id_aluno = alunoId;
    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Curso não encontrado.';
    END IF;
END;
//

DELIMITER ;

CALL AtualizarStatusMatriculaAluno(1, 'Curso 1', 'Área 1');

DELIMITER //

CREATE FUNCTION ObterIdDoCurso(nomeCurso VARCHAR(255), areaCurso VARCHAR(255))
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE cursoId INT;
    SELECT id_curso INTO cursoId FROM curso WHERE nome_curso = nomeCurso AND area = areaCurso;
    RETURN cursoId;
END;
//

DELIMITER ;



