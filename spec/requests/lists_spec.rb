require "rails_helper"

RSpec.describe "Boards", type: :request do
    let(:user) { create(:user) }
    let(:board) { create(:board, user: user) }
    let(:list) { create(:list, board: board) }

    before do
        sign_in user
    end

    describe "GET new" do
        it "Cria uma nova Lista de Tarefas" do
            get new_board_list_path(board)
            expect(response).to have_http_status(:success)
        end
    end

    describe "GET edit" do
        it "Edita um Lista de Tarefas já criada" do
            get edit_board_list_path(board, list)
            expect(response).to have_http_status(:success)
        end
    end


    describe "POST create" do
        context "Criar uma lista de tarefas com os parametros validos" do
            it "Cria uma nova lista de tarefas e redireciona" do
                expect do 
                    post board_lists_path(board), params: {
                        list: {
                            title: "Nova Lista"
                        }
                    }
                end.to change { List.count }.by(1)
                expect(response).to have_http_status(:redirect)
            end
        end
            
        context "Criar uma lista de tarefas com os parametros validos" do
            it "Não cria uma nova lista de tarefas e renderiza a pagina de criação de tarefa" do
                expect do
                    post board_lists_path(board), params: {
                        list: {
                            title: ""
                        }
                    }
                end.not_to change { List.count }
                expect(response).to have_http_status(:success)
            end
        end
    end

   
    describe "PUT update" do
        context "Alterar a lista de tarefas com os parametros válidos" do
            it "Altara a lista de tarefas e redireciona para a Home" do
                expect do 
                    put board_list_path(board, list), params: {
                        list: {
                            title: "Alterando a Lista de Tarefas"
                        }
                    }
                end.to change { list.reload.title }.to("Alterando a Lista de Tarefas")
                expect(response).to have_http_status(:redirect)
            end
        end
    
        context "Alterar a lista de tarefas com os parametros inválidos" do
            it "Não altera a lista de tarefas e renderiza a página de alteração da tarefa" do
                expect do 
                    put board_list_path(board, list), params: {
                        list: {
                            title: ""
                        }
                    }
                end.not_to change { list.reload.title }
                expect(response).to have_http_status(:success)
            end
        end
    end
 
    describe "DELETE destroy" do
        it "Exclui uma Lista de Tarefas" do
            list
            expect do 
                delete board_list_path(board, list), headers: { "ACCEPT": "application/json" }
            end.to change { List.count }.by(-1)
            expect(response).to have_http_status(:success)
        end
    end

end
