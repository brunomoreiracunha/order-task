require "rails_helper"

RSpec.describe "Boards", type: :request do
    let(:user) { create(:user) }
    let(:board) { create(:board, user: user) }

    before do
        sign_in user
    end

    describe "GET new" do
        it "succeds" do
            get new_board_path
            expect(response).to have_http_status(:success)
        end
    end

    describe "GET edit" do
        it "succeds" do
            get edit_board_path(board)
            expect(response).to have_http_status(:success)
        end
    end

    describe "GET show" do
        it "succeds" do
            get edit_board_path(board)
            expect(response).to have_http_status(:success)
        end
    end

    describe "POST create" do
        context "Criar uma tarefa com os parametros validos" do
            it "Cria uma nova tarefa e redireciona" do
                expect do 
                    post boards_path, params: {
                        board: {
                            name: "Nova Tarefa"
                        }
                    }
                end.to change { Board.count }.by(1)
                expect(response).to have_http_status(:redirect)
            end
        end
        
        context "Criar uma tarefa com os parametros validos" do
            it "Não cria uma nova tarefa e renderiza a pagina de criação de tarefa" do
                expect do
                    post boards_path, params: {
                        board: {
                            name: ""
                        }
                    }
                end.not_to change { Board.count }
                expect(response).to have_http_status(:success)
            end
        end
    end

    describe "PUT update" do
        context "Alterar a tarefa com os parametros válidos" do
            it "Altara a tarefa e redireciona para a Home" do
                expect do 
                    put board_path(board), params: {
                        board: {
                            name: "Alterando a Tarefa"
                        }
                    }
                end.to change { board.reload.name }.to("Alterando a Tarefa")
                expect(response).to have_http_status(:redirect)
            end
        end

        context "Alterar a tarefa com os parametros inválidos" do
            it "Não altera a tarefa e renderiza a página de alteração da tarefa" do
                expect do 
                    put board_path(board), params: {
                        board: {
                            name: ""
                        }
                    }
                end.not_to change { board.reload.name }
                expect(response).to have_http_status(:success)
            end
        end
    end
    
    describe "DELETE destroy" do
        it "Exclui a tarefa e redireciona para a Home" do
            board
            expect do 
                delete board_path(board)
            end.to change { Board.count }.by(-1)
            expect(response).to have_http_status(:redirect)
        end
    end
end
